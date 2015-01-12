require 'sinatra'
require 'github/markup'
require_relative '../lib/app.rb'
require_relative 'v1/lib/api_error.rb'

ENV['CHROMA_ENV'] ||= 'vagrant'

App.configure!( ENV['CHROMA_ENV'] ) unless App.configured?

VIEW_PATH = File.join( File.dirname(__FILE__), 'v1', 'views' )
STATIC_PATH = File.join( File.dirname(__FILE__), 'v1', 'static', 'public' )
STATIC_SRC_PATH = File.join( File.dirname(__FILE__), 'v1', 'static', 'src' )

set :views, VIEW_PATH
set :public_folder, STATIC_PATH

# UTILITY METHODS ------------------------------------------------------------

def password_protected!
  return if password_authorized?
  headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
  halt 401, "Not authorized\n"
end

def password_authorized?
  return true unless ENV['CHROMA_ENV'] == 'staging'
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['chromadmin', 't0ps3kr!t']
end

# creates a documentation path for the given resource.
# This API is self documenting!
def doc( path )
  get "#{path}.html" do
    password_protected!
    
    endpoint = path.split('/').last
    
    template_path = File.join( VIEW_PATH, "#{endpoint}.md" )
    rendered = GitHub::Markup.render( template_path )

    erb :layout, :locals => { :content => rendered }
  end
end

# adds some universal headers for every response.
def add_headers
  # processing time is expressed in miliseconds
  processing_time = ((Time.now - @_start_time) * 1000).to_i
  headers['Chroma-Processing-MS'] = processing_time.to_s
end

# indicates that a particular path is not implemented; handy for work in progress.
def not_implemented
  @errors.add("Not implemented.")
end

# SECURITY CHECKS ------------------------------------------------------------

def token_present?
  !params[:token_id].nil?
end


def secret_auth_present?
  params[:user_id] and params[:secret_key]
end


def require_secret_key!
  return false unless secret_auth_present?
  
  @user = User.with_secret_key( params[:user_id], params[:secret_key] )
  return false unless @user

  true
end


def require_token!
  return false unless token_present?
  
  @token = Token.get( params[:token_id] )
  return false unless @token

  @user = User.get( @token.user_id )
  return false unless @user

  true
end


def require_service_token!
  return false unless token_present?

  return false unless App.config["services"]["token"] == params[:token_id]
  
  true
end


def invalid_credentials!
  status 401
  @errors.add "Invalid credentials."
end


# FILTERS --------------------------------------------------------------------

# sets up universally available variables
before do
  # all requests get processing time
  @_start_time = Time.now  
  @errors = APIError.new
  @out = nil
end

# ensures all JSON end points have the correct Content-Type
before("*.json") do
  content_type "application/json"
end

# adds headers to all requests, and handles @error and @out
# conversions to JSON.
after do
  add_headers
  
  if @errors.empty? and !@out.nil?
    halt @out.to_json
  elsif !@errors.empty?
    halt @errors.to_json
  end
end

if development?
  set :show_exceptions, false
  error do
    puts "\n --- \n #{env['sinatra.error'].inspect}\n#{env['sinatra.error'].backtrace.join("\n\t")} \n"
  end
end


# ROOT ---------------------------------------------------------------------

# get '/' do
#   password_protected!
#   '<img style="width: 100%; height: 100%" src="http://img4.wikia.nocookie.net/__cb20130627171445/safari-zone/images/c/c1/Soon-horse.jpg">'
# end

get '/' do
  password_protected!
  File.read( File.join( STATIC_SRC_PATH, 'index.html' ) )
end

get '/css/:file' do
  content_type "text/css"
  File.read( File.join( STATIC_PATH, 'css', params[:file] ) )
end

get '/js/:file' do
  password_protected!
  content_type "application/javascript"
  File.read( File.join( STATIC_PATH, 'js', params[:file] ) ) 
end

# RESOURCES ----------------------------------------------------------------

doc "/v1/index"

require_relative 'v1/lib/ledger.rb'
require_relative 'v1/lib/users.rb'
require_relative 'v1/lib/pools.rb'
require_relative 'v1/lib/projects.rb'
require_relative 'v1/lib/queues.rb'
require_relative 'v1/lib/tokens.rb'
require_relative 'v1/lib/wallets.rb'

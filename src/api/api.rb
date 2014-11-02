require 'sinatra'
require_relative '../lib/app.rb'
require_relative '../lib/distribution.rb'
require_relative './api_error.rb'

# creates a documentation path for the given resource.
# This API is self documenting!
def doc( path )
  get "#{path}.html" do
    markdown path.to_sym, layout: "v1/layout".to_sym, layout_engine: :erb
  end
end

def add_headers
  # processing time is expressed in miliseconds
  processing_time = ((Time.now - @_start_time) * 1000).to_i
  headers['Chroma-Processing-MS'] = processing_time
end

App.configure!( ENV['CHROMA_ENV'] || 'vagrant' )

get '/' do
  '<img style="width: 100%; height: 100%" src="http://img4.wikia.nocookie.net/__cb20130627171445/safari-zone/images/c/c1/Soon-horse.jpg">'
end

before do
  # all requests get processing time
  @_start_time = Time.now  
  @errors = APIError.new
  @out = nil
end

before("*.json") do
  content_type "application/json"
end

after do
  add_headers
  
  if @errors.empty? and !@out.nil?
    halt @out.to_json
  elsif !@errors.empty?
    halt @errors.to_json
  end
end

doc '/v1/distributions'
get '/v1/distributions.json' do
  pool_id = params[:pool_id]
  d = Distribution.new( pool_id )
  if d.load!
    @out = d
  else
    status 404
    @errors.add("No distribution found with pool_id #{pool_id}")
  end
end

post '/v1/distributions.json' do
  raw = JSON.parse( params[:distribution] )
  d = Distribution.new( raw['pool_id'] )
  raw['splits'].each do |account_id, split_pct|
    d.split!( account_id, BigDecimal.new( split_pct ) )
  end

  if d.valid?
    d.save
    @out = d
  else
    d.errors.each { |de| @errors.add( de ) }
  end
end

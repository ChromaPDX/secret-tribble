require 'sinatra'
require_relative '../lib/app.rb'
require_relative './api_error.rb'

App.configure!( ENV['CHROMA_ENV'] || 'vagrant' )


# UTILITY METHODS ------------------------------------------------------------

# creates a documentation path for the given resource.
# This API is self documenting!
def doc( path )
  get "#{path}.html" do
    markdown path.to_sym, layout: "v1/layout".to_sym, layout_engine: :erb
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


# ROOT ---------------------------------------------------------------------

get '/' do
  '<img style="width: 100%; height: 100%" src="http://img4.wikia.nocookie.net/__cb20130627171445/safari-zone/images/c/c1/Soon-horse.jpg">'
end


# RESOURCES ----------------------------------------------------------------

require_relative 'v1/distributions.rb'

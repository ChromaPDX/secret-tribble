require 'sinatra'
require_relative '../lib/app.rb'
require_relative '../lib/distribution.rb'

App.configure!

get '/' do
  "hello, world! #{App.db[:distributions].count}"
end

get '/v1/distributions' do
  pool_id = params[:pool_id]
  d = Distribution.new( pool_id )
  d.load!

  d.splits.to_json
end

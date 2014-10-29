require 'sinatra'
require_relative '../lib/app.rb'
require_relative '../lib/distribution.rb'

App.configure! ENV['RACK_ENV']

get '/' do
  "hello, world! #{App.db[:distributions].count}"
end

get '/v1/distributions' do
  pool_id = params[:pool_id]
  d = Distribution.new( pool_id )
  d.load!

  d.to_json
end

post '/v1/distributions' do
  raw = JSON.parse( params[:distribution] )
  d = Distribution.new( raw['pool_id'] )
  raw['splits'].each do |account_id, split_pct|
    d.split!( account_id, BigDecimal.new( split_pct ) )
  end
  d.save!

  d.to_json
end

require 'sinatra'
require_relative '../lib/app.rb'
require_relative '../lib/distribution.rb'

App.configure!( ENV['CHROMA_ENV'] || 'vagrant' )

get '/' do
  '<img style="width: 100%; height: 100%" src="http://img4.wikia.nocookie.net/__cb20130627171445/safari-zone/images/c/c1/Soon-horse.jpg">'
end

get '/v1/distributions' do
  pool_id = params[:pool_id]
  d = Distribution.new( pool_id )
  if d.load!
    d.to_json
  else
    status 404
    { errors: ["No distribution found with pool_id #{pool_id}"] }.to_json
  end
end

post '/v1/distributions' do
  raw = JSON.parse( params[:distribution] )
  d = Distribution.new( raw['pool_id'] )
  raw['splits'].each do |account_id, split_pct|
    d.split!( account_id, BigDecimal.new( split_pct ) )
  end

  if d.valid?
    d.save
    d.to_json
  else
    { errors: d.errors }.to_json
  end
end

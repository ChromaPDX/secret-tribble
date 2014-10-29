require 'sinatra'
require_relative '../lib/app.rb'

App.configure!

get '/' do
  "hello, world! #{App.db[:distributions].count}"
end

ENV['RACK_ENV'] = ENV['CHROMA_ENV'] = "test"

require_relative "../api.rb"
require 'rspec'
require 'rack/test'

describe 'The API' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should say hello" do
    get "/"
    expect(last_response).to be_ok
  end

end

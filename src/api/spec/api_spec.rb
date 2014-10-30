ENV['RACK_ENV'] = "test"

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

  it "should retrieve a distribution" do
    pool_id = App.unique_id
    d = Distribution.new( pool_id )
    d.split!("alice", BigDecimal.new("0.5"))
    d.split!("bob", BigDecimal.new("0.3"))
    d.split!("carol", BigDecimal.new("0.2"))
    d.save

    get "/v1/distributions", pool_id: pool_id
    expect(last_response).to be_ok

    j = JSON.parse( last_response.body )
    expect(j['created_at']).to eq(d.created_at.to_s)

  end

end

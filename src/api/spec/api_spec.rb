ENV['RACK_ENV'] = 'test'
ENV['CHROMA_ENV'] = 'test'

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

  it "GET /v1/distributions should retrieve a valid distribution" do
    pool_id = App.unique_id
    d = Distribution.new( pool_id )
    d.split!("alice", BigDecimal.new("0.5"))
    d.split!("bob", BigDecimal.new("0.3"))
    d.split!("carol", BigDecimal.new("0.2"))
    d.save

    get "/v1/distributions", pool_id: pool_id
    expect(last_response).to be_ok

    j = JSON.parse( last_response.body )

    # data integrity check
    expect(j['pool_id']).to eq(d.pool_id)
    expect(j['created_at']).to eq(d.created_at.to_s)
    j['splits'].each do |account, split_pct|
      expect(d.splits[account]).to eq(BigDecimal.new(split_pct))
    end
  end

  it "GET /v1/distributions should return 404 and a useful error message when it can't find a distribution" do
    get "/v1/distributions", pool_id: App.unique_id
    expect(last_response.status).to eq(404)
    
    j = JSON.parse(last_response.body)
    expect( j['error'] ).not_to be_nil
  end

end

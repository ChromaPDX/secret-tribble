ENV['RACK_ENV'] = 'test'
ENV['CHROMA_ENV'] = 'test'

require_relative "../api.rb"
require 'rspec'
require 'rack/test'

def valid_distribution
  d = Distribution.new( App.unique_id )
  d.split!("alice", BigDecimal.new("0.5"))
  d.split!("bob", BigDecimal.new("0.3"))
  d.split!("carol", BigDecimal.new("0.2"))

  d
end

def check_headers( resp )
  expect( resp.headers['Content-Type'] ).to eq("application/json")
end

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
    d = valid_distribution
    d.save
    
    get "/v1/distributions", pool_id: d.pool_id
    expect(last_response).to be_ok
    check_headers last_response

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
    check_headers last_response
    
    j = JSON.parse(last_response.body)
    expect( j['errors'] ).not_to be_nil
  end

  it "POST /v1/distributions should create a distribution in the database" do
    d = valid_distribution
    post "/v1/distributions", distribution: d.to_json
    expect(last_response).to be_ok
    check_headers last_response
    j_created = JSON.parse last_response.body

    get "/v1/distributions", pool_id: d.pool_id
    expect(last_response).to be_ok
    check_headers last_response
    j_retrieved = JSON.parse last_response.body

    expect( j_retrieved ).to eq(j_created)
  end

  it "POST /v1/distributions should return a useful error message if it fails to create a distribution" do
    d = valid_distribution
    
    # invalidate the distribution
    d.split! "joe", BigDecimal.new("0.2")
    expect( d.valid? ).to eq(false)

    post "/v1/distributions", distribution: d.to_json
    j = JSON.parse( last_response.body )
    check_headers last_response
    expect( j['errors'] ).to be_an(Array)
  end
  
end

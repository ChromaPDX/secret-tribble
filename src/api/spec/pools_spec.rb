require_relative "helper"

describe '/v1/pools' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "GET /v1/pools.html should provide documentation" do
    get "/v1/pools.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end
  
  it "GET should retrieve a valid pool" do
    d = valid_pool
    d.save
    
    get "/v1/pools.json", pool_id: d.pool_id
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

  it "GET should return 404 and a useful error message when it can't find a pool" do
    get "/v1/pools.json", pool_id: App.unique_id
    expect(last_response.status).to eq(404)
    check_headers last_response
    
    j = JSON.parse(last_response.body)
    expect( j['errors'] ).not_to be_nil
  end

  it "POST should create a pool in the database" do
    d = valid_pool
    post "/v1/pools.json", pool: d.to_json
    expect(last_response).to be_ok
    check_headers last_response
    j_created = JSON.parse last_response.body

    get "/v1/pools.json", pool_id: d.pool_id
    expect(last_response).to be_ok
    check_headers last_response
    j_retrieved = JSON.parse last_response.body

    expect( j_retrieved ).to eq(j_created)
  end

  it "POST should return a useful error message if it fails to create a pool" do
    d = valid_pool
    
    # invalidate the pool
    d.split! "joe", BigDecimal.new("0.2")
    expect( d.valid? ).to eq(false)

    post "/v1/pools.json", pool: d.to_json
    j = JSON.parse( last_response.body )
    check_headers last_response
    expect( j['errors'] ).to be_an(Array)
  end

  
end

require_relative 'helper'
require_relative '../../lib/revenue'

describe "/v1/revenue" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    setup_credentials
  end

  
  it "GET /v1/revenue.html should provide documentation" do
    get "/v1/revenue.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end

  it "GET should return a specific revenue event" do
    r = Revenue.new( pool_id: App.unique_id,
                     amount: BigDecimal.new( "123.4567" ),
                     currency: Revenue::BTC )
    r.create!

    get "/v1/revenue.json", token_id: @token_id, revenue_id: r.revenue_id
    check_headers

    j = get_json
    expect( j['revenue_id'] ).to eq(r.revenue_id)
    expect( j['pool_id'] ).to eq(r.pool_id)
    expect( BigDecimal.new( j['amount'] ) ).to eq(r.amount)
    expect( j['currency'] ).to eq(r.currency)
    expect( j['created_at'].to_s ).to eq(r.created_at.to_s)
  end

  it "GET should return all of the revenue events for a pool" do
    pool_id = App.unique_id
    r1 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "12.3" ),
                      currency: Revenue::BTC )
    r1.create!

    r2 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "45.6" ),
                      currency: Revenue::BTC )
    r2.create!

    r3 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "78.9" ),
                      currency: Revenue::BTC )
    r3.create!

    get "/v1/revenue.json", token_id: @token_id, pool_id: pool_id
    check_headers
    j = get_json

    # we have reasonable assurance that this will provide the three revenue
    # objects above; please see the lib/specs/revenue_spec.rb
    expect( j ).to be_an(Array)
    expect( j.length ).to eq(3)
  end

  it "POST should create a new revenue event" do
    pool_id = App.unique_id
    amount_str = "3.14159"
    currency = Revenue::BTC

    post "/v1/revenue.json", token_id: @token_id, pool_id: pool_id, amount: amount_str, currency: currency
    check_headers
    j = get_json

    expect( j['pool_id'] ).to eq(pool_id)
    expect( BigDecimal.new(j['amount']) ).to eq(BigDecimal.new( amount_str ))
    expect( j['revenue_id'] ).to_not be_nil
    expect( j['created_at'] ).to_not be_nil
    expect( j['currency'] ).to eq(Revenue::BTC)
  end

  


end

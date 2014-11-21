require_relative "helper"

describe '/v1/wallets.json' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    setup_credentials
    @wallet = Wallet.new( relation_id: App.unique_id,
                          kind: Wallet::ORIGIN_KIND,
                          currency: Wallet::BTC_CURRENCY,
                          identifier: App.unique_id)
    @wallet.save!
  end

  
  it "GET /v1/wallets.html should provide documentation" do
    get "/v1/wallets.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end


  it "GET should retrieve a wallet, and require a valid token" do
    # make sure we have credentials
    get '/v1/wallets.json'
    check_headers nil, 401
    check_errors nil, "Invalid credentials."

    # no wallet_id? all of the user's wallets
    get '/v1/wallets.json', token_id: @token_id
    check_headers
    j = get_json
    expect( j ).to be_an( Array )
    
    # legit basic request by wallet_id
    get '/v1/wallets.json', token_id: @token_id, wallet_id: @wallet.wallet_id
    check_headers
    j = get_json

    expect( @wallet.wallet_id ).to eq(j['wallet_id'])
    expect( @wallet.relation_id ).to eq(j['relation_id'])
    expect( @wallet.created_at.to_s ).to eq(j['created_at'])
    expect( @wallet.kind ).to eq(j['kind'])
    expect( @wallet.currency ).to eq(j['currency'])
    expect( @wallet.identifier ).to eq(j['identifier'])

    # legit basic request by kind and identifier
    get '/v1/wallets/search.json', token_id: App.config['services']['token'], kind: @wallet.kind, identifier: @wallet.identifier
    check_headers
    j = get_json

    expect( @wallet.wallet_id ).to eq(j['wallet_id'])    
  end

  it "POST should require a valid token"

  it "GET and POST should be constrained to a user associated with the wallet!"

end

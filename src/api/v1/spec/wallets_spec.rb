require_relative "helper"

describe '/v1/wallets.json' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    setup_credentials
    @wallet = Wallet.new(account_id: App.unique_id,
                         kind: Wallet::ORIGIN_KIND,
                         currency: Wallet::BITCOIN_CURRENCY,
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

    # no wallet_id? error
    get '/v1/wallets.json', token_id: @token_id
    check_headers
    check_errors
    
    # legit basic request
    get '/v1/wallets.json', token_id: @token_id, wallet_id: @wallet.wallet_id
    check_headers
    j = get_json

    expect( @wallet.wallet_id ).to eq(j['wallet_id'])
    expect( @wallet.account_id ).to eq(j['account_id'])
    expect( @wallet.created_at.to_s ).to eq(j['created_at'])
    expect( @wallet.kind ).to eq(j['kind'])
    expect( @wallet.currency ).to eq(j['currency'])
    expect( @wallet.identifier ).to eq(j['identifier'])
  end

  
  it "POST should require a valid token"

  it "GET and POST should be constrained to a user associated with the wallet!"

end

require_relative 'helper'

describe '/v1/tokens' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  before(:all) do
    @secret_key = App.unique_id
    @account = Account.create!("test account")
    @account_id = @account.account_id
    @account.set_secret_key( @secret_key )

    @metadata = "example_token"
    @token = Token.create!( @account_id, @metadata )
  end
  
  
  it "POST given correct credentials, it should create a new token" do
    # success case
    post "/v1/tokens.json", account_id: @account_id, secret_key: @secret_key
    expect(last_response).to be_ok
    j = JSON.parse(last_response.body)
    expect(j["account_id"]).to eq(@account_id)
    expect(j["token_id"]).to_not be nil

    # failure case: bad account_id
    post "/v1/tokens.json", account_id: "asfasf", secret_key: @secret_key
    expect(last_response.status).to be 401 # Not Authenticated
    j = JSON.parse(last_response.body)
    expect(j['errors']).to be_an(Array)
    
    # failure case: missing account_id and secret_key
    post "/v1/tokens.json"
    expect(last_response.status).to be 401 # Not Authenticated
    j = JSON.parse(last_response.body)
    expect(j['errors']).to be_an(Array)
  end

  
  it "GET given correct credentials, it should list all tokens" do
    # success case
    get "/v1/tokens.json", account_id: @account_id, secret_key: @secret_key
    expect(last_response).to be_ok
    j = JSON.parse(last_response.body)
    expect(j["tokens"]).to be_an(Array)
    j["tokens"].each do |t|
      expect(t["account_id"]).to eq(@account_id)
    end
    check_headers(last_response)

    # failure case: bad account_id
    get "/v1/tokens.json", account_id: "asfasf", secret_key: @secret_key
    expect(last_response.status).to eq(401) # Not Authenticated
    j = JSON.parse(last_response.body)
    expect(j['errors']).to be_an(Array)
    check_headers(last_response)
    
    # failure case: missing account_id and secret_key
    get "/v1/tokens.json"
    expect(last_response.status).to eq(401) # Not Authenticated
    j = JSON.parse(last_response.body)
    expect(j['errors']).to be_an(Array)
    check_headers(last_response)
  end

  
  it "DELETE given correct credentials, should delete a token" do
    t1 = Token.create!( @account_id, "delete me" )
    t2 = Token.get( t1.token_id )
    expect( t2 ).to_not be false

    delete "/v1/tokens.json", account_id: @account_id, secret_key: @secret_key, token_id: t1.token_id
    expect(last_response).to be_ok
    check_headers(last_response)

    t2 = Token.get( t1.token_id )
    expect( t2 ).to be false
  end
  
  it "HEAD should verify that a token is active" do
    # success
    head "/v1/tokens.json", token_id: @token.token_id
    expect(last_response).to be_ok
    check_headers(last_response)

    # failure
    head "/v1/tokens.json", token_id: App.unique_id
    expect(last_response.status).to eq(401)
    check_headers(last_response)
  end

end

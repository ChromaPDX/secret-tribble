require_relative 'helper'

describe '/v1/tokens' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  before(:all) do
    setup_credentials
  end
  
  
  it "POST given correct credentials, it should create a new token" do
    # success case
    post "/v1/tokens.json", user_id: @user_id, secret_key: @secret_key
    check_headers last_response

    j = JSON.parse(last_response.body)
    expect(j["user_id"]).to eq(@user_id)
    expect(j["token_id"]).to_not be nil

    # failure case: bad user_id
    post "/v1/tokens.json", user_id: "asfasf", secret_key: @secret_key
    check_headers last_response, 401
    check_errors last_response
    
    # failure case: missing user_id and secret_key
    post "/v1/tokens.json"
    check_headers last_response, 401
    check_errors last_response
  end

  
  it "GET given correct credentials, it should list all tokens" do
    # success case
    get "/v1/tokens.json", user_id: @user_id, secret_key: @secret_key
    check_headers last_response
    j = JSON.parse(last_response.body)
    expect(j["tokens"]).to be_an(Array)
    j["tokens"].each do |t|
      expect(t["user_id"]).to eq(@user_id)
    end

    # failure case: bad user_id
    get "/v1/tokens.json", user_id: "asfasf", secret_key: @secret_key
    check_headers last_response, 401
    check_errors last_response
    
    # failure case: missing user_id and secret_key
    get "/v1/tokens.json"
    check_headers last_response, 401
    check_errors last_response
    
  end

  
  it "DELETE given correct credentials, should delete a token" do
    t1 = Token.create!( @user_id, "delete me" )
    t2 = Token.get( t1.token_id )
    expect( t2 ).to_not be false

    delete "/v1/tokens.json", user_id: @user_id, secret_key: @secret_key, token_id: t1.token_id
    check_headers last_response

    t2 = Token.get( t1.token_id )
    expect( t2 ).to be false
  end

  
  it "HEAD should verify that a token is active" do
    # success
    head "/v1/tokens.json", token_id: @token.token_id
    check_headers last_response

    # failure
    head "/v1/tokens.json", token_id: App.unique_id
    check_headers last_response, 401
  end

end

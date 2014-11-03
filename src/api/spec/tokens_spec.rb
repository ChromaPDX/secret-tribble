require_relative 'helper'

describe '/v1/tokens' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  before(:all) do
    @account_id = App.unique_id
    @metadata = "example_token"
    @token = Token.create!( @account_id, @metadata )
  end

  
  it "POST /v1/tokens.json given correct credentials, it should create a new token"

  
  it "GET /v1/tokens.json given correct credentials, it should list all tokens"

  
  it "DELETE /v1/tokens.json given correct credentials, should delete a token"
  
  
  it "GET /v1/tokens.json should verify that a token is active" do
    # success
    get "/v1/tokens.json", token_id: @token.token_id
    expect(last_response).to be_ok
    check_headers(last_response)

    # failure
    get "/v1/tokens.json", token_id: App.unique_id
    expect(last_response.status).to eq(404)
    j = JSON.parse(last_response.body)
    expect( j['errors'].empty? ).to be false
  end

  
  it "GET /v1/tokens.json should verify that all of the token data is available" do
    get "/v1/tokens.json", token_id: @token.token_id
    expect(last_response).to be_ok
    check_headers(last_response)

    j = JSON.parse(last_response.body)
    expect( j['token_id'] ).to eq( @token.token_id )
    expect( j['created_at'].to_s ).to eq( @token.created_at.to_s )
    expect( j['metadata'] ).to eq( @token.metadata )
    expect( j['account_id'] ).to eq( @token.account_id )
  end
  
end

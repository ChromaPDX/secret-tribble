require_relative "helper"

describe '/v1/accounts.json' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    setup_credentials
  end

  
  it "GET /v1/accounts.html should provide documentation" do
    get "/v1/accounts.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end

  
  it "GET should retrieve the current account information" do

    # success case
    get "/v1/accounts.json", token_id: @token_id
    check_headers
    j = get_json

    expect( j['account_id'] ).to_not be_nil
    expect( j['created_at'] ).to_not be_nil
    expect( j['name'] ).to_not be_nil

    # failure case
    get "/v1/accounts.json", token_id: "complete fabrication"
    check_headers( nil, 401 )
    check_errors
  end

  it "POST should authenticate based on a user and password, and return a token" do
    
    # success case
    post "/v1/accounts.json", user: @user, password: @password
    check_headers
    j = get_json

    new_token_id = j['token_id']
    expect( new_token_id ).to_not be_nil

    get "/v1/accounts.json", token_id: new_token_id
    check_headers

    account = Account.with_user_pass( @user, @password )
    expect( account ).to_not be false
    expect( j['account_id'] ).to eq( account.account_id )
  end
  
end

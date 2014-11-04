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

  
  it "GET should retrieve the current account information"

  
  it "POST should create an account"
end

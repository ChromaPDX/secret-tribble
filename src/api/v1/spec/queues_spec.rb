require_relative 'helper'

describe "/v1/queues" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @topic = "api test"
    @token_id = App.config["services"]["token"]
  end

  
  it "GET /v1/queues.html should provide documentation" do
    get "/v1/queues.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end

  
  it "GET must require a service token" do
    get "/v1/queues.json"
    check_headers last_response, 401
    check_errors
  end

  
  it "GET should retrieve the latest message for the given queue" do
    q = PersistentQueue.new( @topic )
    q.clear!
    
    msg = { "hello" => "get!" }
    q.push msg
    expect( q.size ).to eq(1)

    get "/v1/queues.json", token_id: @token_id, topic: @topic
    check_headers
    expect( get_json['body'] ).to eq(msg)
    expect( q.size ).to eq(0)
  end

  
  it "POST must require a service token" do
    post "/v1/queues.json"
    check_headers last_response, 401
    check_errors
  end

  it "POST should insert a message into the given queue" do
    q = PersistentQueue.new( @topic )
    q.clear!
    
    msg = { "hello" => "post!" }
    post "/v1/queues.json", token_id: @token_id, topic: @topic, body: msg.to_json
    check_headers
    expect( get_json['body'] ).to eq(msg)
    expect( q.size ).to eq(1)
  end
  
end

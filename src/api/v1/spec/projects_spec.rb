require_relative "helper"

describe '/v1/projects.json' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    setup_credentials
    @pool = valid_pool
    @pool.save

    @project = Project.new(name: "herp derp", pool_id: @pool.pool_id )
    @project.save!
  end

  
  it "GET /v1/projects.html should provide documentation" do
    get "/v1/projects.html"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type'] ).to eq("text/html;charset=utf-8")
  end


  it "GET should retrieve a project, and require a valid token" do
    # make sure we have credentials
    get '/v1/projects.json'
    check_headers nil, 401
    check_errors nil, "Invalid credentials."

    # legit basic request
    get '/v1/projects.json', token_id: @token_id, project_id: @project.project_id
    check_headers
    j = get_json

    expect( @project.project_id ).to eq(j['project_id'])
    expect( @project.pool_id ).to eq(j['pool_id'])
    expect( @project.name ).to eq(j['name'])
    expect( @project.created_at.to_s ).to eq(j['created_at'])
  end

  
  it "POST should require a valid token"

  it "GET and POST should be constrained to a user associated with the project!"

  it "GET without project_id should return all of the projects for that user" # NOTE: This is used and works in the API
  
end

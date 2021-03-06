
# some intialization hacks needed before we include api.rb
require 'rspec'
require 'rack/test'
require 'fileutils'
require_relative '../../../lib/app'
ENV['CHROMA_ENV'] ||= 'test'
FileUtils.rm_f App.log_file_path(ENV['CHROMA_ENV'])
App.configure!( ENV['CHROMA_ENV'] )

require_relative '../../api.rb'

require_relative '../../../lib/pool.rb'
require_relative '../../../lib/token.rb'
require_relative '../../../lib/user.rb'
require_relative '../../../lib/persistent_queue.rb'
require_relative '../../../lib/project.rb'

RSpec.configure do |cfg|
  cfg.before(:suite) do
    # wipe everything out of the test database
    App.db_tables.each do |table|
      App.db[table].delete
    end
  end
end

# HELPER METHODS -------------------------------------------------------------


# We have several custom headers to assist with debugging
def check_headers( resp = nil, status = 200 )
  resp ||= last_response

  # print out the 500 error if we have one!
  puts resp.body if resp.status == 500
  
  expect( resp.status ).to eq(status)
  expect( resp.headers['Content-Type'] ).to eq("application/json")
  expect( resp.headers['Chroma-Processing-MS'] ).to_not be_nil
end


# extracts a JSON object from the response body
def get_json( resp = nil )
  resp ||= last_response
  JSON.parse( resp.body )
end


# Checks an expected error object
def check_errors( resp = nil, error_string = false )
  resp ||= last_response
  j = JSON.parse( resp.body )
  expect(j['errors']).to be_an(Array)
  
  if error_string
    expect(j['errors'].include?( error_string )).to be(true)
  end
end


def valid_pool
  d = Pool.new( App.unique_id )
  d.split!("alice", BigDecimal.new("0.5"))
  d.split!("bob", BigDecimal.new("0.3"))
  d.split!("carol", BigDecimal.new("0.2"))

  d
end


# creates the environment needed to authenticate requests
def setup_credentials
  @secret_key = App.unique_id
  @username = "test+#{App.unique_id}@test.com"
  @password = App.unique_id
  @user = User.create! "test user"
  @user_id = @user.user_id
  @user.set_secret_key( @secret_key )
  @user.set_username_pass( @username, @password )
  @metadata = "example token"
  @token = Token.create!( @user_id, @metadata )
  @token_id = @token.token_id
end

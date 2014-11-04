
# some intialization hacks needed before we include api.rb
require 'rspec'
require 'rack/test'
require 'fileutils'
require_relative '../../lib/app'
ENV['CHROMA_ENV'] ||= 'test'
FileUtils.rm_f App.log_file_path(ENV['CHROMA_ENV'])
App.configure!( ENV['CHROMA_ENV'] )

require_relative '../api.rb'

require_relative '../../lib/pool.rb'
require_relative '../../lib/token.rb'
require_relative '../../lib/account.rb'

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
def check_headers( resp, status = 200 )
  expect( resp.headers['Content-Type'] ).to eq("application/json")
  expect( resp.headers['Chroma-Processing-MS'] ).to_not be_nil
  expect( resp.status ).to eq(status)
end


def valid_pool
  d = Pool.new( App.unique_id )
  d.split!("alice", BigDecimal.new("0.5"))
  d.split!("bob", BigDecimal.new("0.3"))
  d.split!("carol", BigDecimal.new("0.2"))

  d
end

def setup_credentials
  @secret_key = App.unique_id
  @account = Account.create! "test account"
  @account_id = @account.account_id
  @account.set_secret_key( @secret_key )
  @metadata = "example token"
  @token = Token.create!( @account_id, @metadata )
  @token_id = @token.token_id
end

require_relative 'helper'
require_relative '../account'

describe "Account" do

  before(:all) do
    @account_id = App.unique_id
  end

  it "should store and retrieve username and passwords hashed with bcrypt and a salt" do
    username = "derp@derp.com"
    password = "yolo"

    # success case
    a = Account.create!("derp derp")
    a.set_user_pass( username, password )
    b = Account.with_user_pass( username, password )
    expect( a.account_id ).to eq( b.account_id )

    # failure case
    c = Account.with_user_pass( username, "not really the password" )
    expect( c ).to be false
  end

  it "should store and retrieve secret keys hashed with bcrypt and a salt" do
    secret_key = "yolo"

    # success case
    a = Account.create!("derp derp")
    a.set_secret_key( secret_key )
    b = Account.with_secret_key( a.account_id, secret_key )
    expect( a.account_id ).to eq( b.account_id )

    # failure case
    c = Account.with_secret_key( a.account_id, "not really the secret key" )
    expect( c ).to be false
  end


end

require_relative 'helper'
require_relative '../user'

describe "User" do

  before(:all) do
    @user_id = App.unique_id
  end

  it "should store and retrieve username and passwords hashed with bcrypt and a salt" do
    username = "derp@derp.com"
    password = "yolo"

    # success case
    a = User.create!("derp derp")
    a.set_username_pass( username, password )
    b = User.with_username_pass( username, password )
    expect( a.user_id ).to eq( b.user_id )

    # failure case
    c = User.with_username_pass( username, "not really the password" )
    expect( c ).to be false
  end

  it "should enforce a unique identifier and kind for a user" do
    username = "notunique@gmail.com"
    password = "yolo"
    u1 = User.create!("dummy")
    expect( u1.set_username_pass( username, password ) ).to be true

    u2 = User.create!("other dummy")
    expect( u2.set_username_pass( username, password ) ).to be false
  end

  it "should store and retrieve secret keys hashed with bcrypt and a salt" do
    secret_key = "yolo"

    # success case
    a = User.create!("derp derp")
    a.set_secret_key( secret_key )
    b = User.with_secret_key( a.user_id, secret_key )
    expect( a.user_id ).to eq( b.user_id )

    # failure case
    c = User.with_secret_key( a.user_id, "not really the secret key" )
    expect( c ).to be false
  end


end

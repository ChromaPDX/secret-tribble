require_relative 'helper'
require_relative '../token'

describe "Token" do

  # postgresql looses a tiny bit of timestamp resolution, so
  # direct comparison fails. We only care about second resolution here.
  def check_timestamps( t1, t2 )
    expect( t1.to_s ).to eq( t2.to_s )
  end

  
  before(:all) do
    @user_id = App.unique_id
  end

  
  it "should create a new token for a given user" do
    metadata = "some string"
    
    t = Token.create!( @user_id, metadata )

    expect( t.token_id ).to be_a(String)
    expect( t.user_id ).to eq(@user_id)
    expect( t.metadata ).to eq(metadata)
  end

  
  it "should retrieve all of the tokens for a given user" do
    ts = Token.all_for( @user_id )

    expect( ts.length ).to be > 0
    ts.each do |t|
      expect( t.user_id ).to eq(@user_id)
      expect( t.metadata ).to be_a(String)
      expect( t.token_id ).to be_a(String)
    end
  end

  
  it "should retrieve a token given a token_id" do
    t = Token.create!( @user_id )

    t2 = Token.get( t.token_id )
    expect( t2.token_id ).to eq( t.token_id )
    expect( t2.user_id ).to eq( t.user_id )
    expect( t2.metadata ).to eq( t.metadata )
    check_timestamps( t2.created_at, t.created_at )
  end

  
  it "should validate the presence of an user_id" do
    t = Token.new
    expect( t.valid? ).to be false
    expect( t.errors.length ).to eq( 1 )

    t = Token.new( user_id: @user_id )
    expect( t.valid? ).to be true
    expect( t.errors.length ).to eq( 0 )
  end
  
end

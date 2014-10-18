require_relative "../lib/distribution"
require 'tmpdir'

TMP_DIR = Dir.mktmpdir

def random_id
  (0...8).map { (65 + rand(26)).chr }.join
end

def valid_distribution
  d = Distribution.new( random_id, TMP_DIR )
  d.split!( "alice", 0.5 )
  d.split!( "bob", 0.25 )
  d.split!( "carol", 0.25 )
  
  d
end

describe "Distribution" do

  before(:all) do
    # current implementation writes out JSON files to a tmp folder.
    # Lets make sure it exists and gets cleaned up later after(:all).
    FileUtils.rm_rf(TMP_DIR) if Dir.exists?(TMP_DIR) 
    FileUtils.mkdir_p TMP_DIR
  end

  after(:all) do
    # clean up tmp dir
    FileUtils.rm_rf(TMP_DIR) if Dir.exists?(TMP_DIR) 
  end

  it "should initialize with an empty split" do
    d = Distribution.new( random_id )
    expect( d.splits ).to eq( {} )
  end

  it "should accept splits" do
    d = Distribution.new( random_id )
    d.split!( "alice", 0.5 ) # alice gets 50%
    d.split!( "bob", 0.5 ) # bob gets 50%

    expect( d.splits ).to eq( { "alice" => 0.5, "bob" => 0.5 } )
  end

  it "should remove splits" do
    d = valid_distribution
    
    # valid removals
    d.split!( "carol", 0 )
    expect( d.splits ).to eq( { "alice" => 0.5, "bob" => 0.25 } )

    d.split!( "bob", nil )
    expect( d.splits ).to eq( { "alice" => 0.5 } )
  end

  it "should save and restore splits" do
    d = valid_distribution

    # test save
    expect( d.save ).to be true
    
    # test load
    d2 = Distribution.new( d.pool_id, TMP_DIR )
    expect( d2.load! ).to be true

    # test equivalency
    expect( d2.splits ).to eq( d.splits )
  end

  it "should perform the distribution calculation" do
    d = valid_distribution

    expect( d.distribute( 100 ) ).to eq( { "alice" => 50, "bob" => 25, "carol" => 25 } )
  end

  # validations
  it "should not accept a split key that is not a string"
  it "should not accept a split value that is not a float"
  it "should not accept individual splits greater then 1.0"
  it "should not accept individual splits less than 0.0"
  it "should not accept a sum of splits greater than 1.0"
  it "should not accept a sum of splits less than 1.0"

end

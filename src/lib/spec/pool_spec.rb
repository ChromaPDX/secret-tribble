require_relative "helper"
require_relative '../pool'

def valid_pool( pool_id = App.unique_id )
  d = Pool.new( pool_id )
  d.split!( "alice", BigDecimal.new('0.5') )
  d.split!( "bob", BigDecimal.new('0.25') )
  d.split!( "carol", BigDecimal.new('0.25') )
  
  d
end

describe "Pool" do

  it "should initialize with an empty split" do
    d = Pool.new( App.unique_id )
    expect( d.splits ).to eq( {} )
  end

  
  it "should accept splits" do
    d = Pool.new( App.unique_id )
    d.split!( "alice", BigDecimal.new('0.5') ) # alice gets 50%
    d.split!( "bob", BigDecimal.new('0.5') ) # bob gets 50%

    expect( d.splits ).to eq( { "alice" => BigDecimal.new('0.5'), "bob" => BigDecimal.new('0.5') } )
  end

  
  it "should remove splits" do
    d = valid_pool
    
    # valid removals
    d.split!( "carol", 0 )
    expect( d.splits ).to eq( { "alice" => BigDecimal.new('0.5'),
                                "bob" => BigDecimal.new('0.25') } )

    d.split!( "bob", nil )
    expect( d.splits ).to eq( { "alice" => BigDecimal.new('0.5') } )
  end

  it "should only load the most recent split for a pool" do
    pool_id = App.unique_id
    
    d1 = Pool.new( pool_id )
    d1.split!( "alice", BigDecimal.new('0.5') )
    d1.split!( "bob", BigDecimal.new('0.25') )
    d1.split!( "carol", BigDecimal.new('0.25') )
    d1.save

    sleep 0.1 # enough time for a new timestamp
    
    d2 = Pool.new( pool_id )
    d2.split!( "alice", BigDecimal.new('0.15') )
    d2.split!( "bob", BigDecimal.new('0.75') )
    d2.split!( "carol", BigDecimal.new('0.10') )
    d2.save

    d3 = Pool.new( pool_id )
    d3.load!

    expect( d3.splits ).to eq( d2.splits )
  end

  it "should load the most recent split before a given timestamp" do
    pool_id = App.unique_id
    
    d1 = Pool.new( pool_id )
    d1.split!( "alice", BigDecimal.new('0.5') )
    d1.split!( "bob", BigDecimal.new('0.25') )
    d1.split!( "carol", BigDecimal.new('0.25') )
    d1.save

    sleep 0.1 # enough time for a new timestamp

    d2 = Pool.new( pool_id )
    d2.split!( "alice", BigDecimal.new('0.15') )
    d2.split!( "bob", BigDecimal.new('0.75') )
    d2.split!( "carol", BigDecimal.new('0.10') )
    d2.save

    sleep 0.1 # enough time for a new timestamp
    ts = Time.now
    
    d3 = Pool.new( pool_id )
    d3.split!( "alice", BigDecimal.new('0.35') )
    d3.split!( "bob", BigDecimal.new('0.25') )
    d3.split!( "carol", BigDecimal.new('0.40') )
    d3.save
    
    d4 = Pool.new( pool_id )
    d4.load!( ts )

    expect( d4.splits ).to eq( d2.splits )
  end
  
  
  it "should save and restore splits" do
    d = valid_pool

    # test save
    expect( d.save.length ).to eq( d.splits.keys.length ) 
    
    # test load
    d2 = Pool.new( d.pool_id )
    expect( d2.load! ).to be true

    # test equivalency
    expect( d2.splits ).to eq( d.splits )
  end

  
  it "should perform the pool calculation" do
    d = valid_pool

    expect( d.distribute( 100 ) ).to eq( { "alice" => 50, "bob" => 25, "carol" => 25 } )
  end

  
  it "should create a JSON representation" do
    d = valid_pool
    parsed_js = JSON.parse( d.to_json )
    expect( parsed_js['pool_id'] ).to eq(d.pool_id)
    expect( parsed_js['created_at'] ).to eq(d.created_at)

    parsed_js['splits'].each do |user_id, split_pct|
      expect( BigDecimal.new(split_pct) ).to eq( d.splits[user_id] )
    end
  end

  
  # validations!
  it "should not accept a split key that is not a valid id" do
    d = Pool.new( "derp" )
    d.split!( 0.4523, BigDecimal.new("1.0") )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::BAD_USER_ERROR)).to be true
  end
  
  it "should not accept a split value that is not a BigDecimal" do
    d = Pool.new( "derp" )
    d.split!( "alice", 0.3 )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::PCT_TYPE_ERROR)).to be true
  end
  
  it "should not accept individual splits greater then 1.0" do
    d = Pool.new( "derp" )
    d.split!( "alice", BigDecimal.new("1.3") )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::PCT_RANGE_ERROR)).to be true
  end
  
  it "should not accept individual splits less than 0.0" do
    d = Pool.new( "derp" )
    d.split!( "alice", BigDecimal.new("-0.4") )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::PCT_RANGE_ERROR)).to be true
  end
  
  it "should not accept a sum of splits greater than 1.0" do
    d = Pool.new( "derp" )
    d.split!( "alice", BigDecimal.new('1.0') )
    d.split!( "bob", BigDecimal.new('0.5') )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::TOTAL_SPLIT_ERROR)).to be true
  end
  
  it "should not accept a sum of splits less than 1.0" do
    d = Pool.new( "derp" )
    d.split!( "alice", BigDecimal.new('0.3') )
    d.split!( "bob", BigDecimal.new('0.5') )

    expect(d.valid?).to be false
    expect(d.errors.include?(Pool::TOTAL_SPLIT_ERROR)).to be true
  end

  it "should rename #save to #save!"
  
end

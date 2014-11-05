require_relative 'helper'
require_relative '../revenue.rb'

describe Revenue do

  def valid_revenue
    @string_amount = "5.1234"
    Revenue.new( pool_id: @pool_id,
                 amount: BigDecimal.new( @string_amount ),
                 currency: Revenue::BTC )
  end
  
  before(:all) do
    @pool_id = App.unique_id
  end

  it "should save and restore correctly" do
    r = valid_revenue
    expect(r.valid?).to be true
    expect(r.create!).to_not be_nil
    expect(r.revenue_id).to_not be_nil
    expect(r.created_at).to_not be_nil

    r2 = Revenue.with_revenue_id( r.revenue_id )
    expect(r2.valid?).to be true
    expect(r2.revenue_id).to eq(r.revenue_id)
    expect(r2.pool_id).to eq(r.pool_id)
    expect(r2.amount).to eq(r.amount)
    expect(r2.currency).to eq(r.currency)
    expect(r2.created_at.to_s).to eq(r.created_at.to_s)
  end

  it "should retrieve all revenue for a given pool" do
    pool_id = App.unique_id
    r1 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "12.3" ),
                      currency: Revenue::BTC )
    r1.create!

    r2 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "45.6" ),
                      currency: Revenue::BTC )
    r2.create!

    r3 = Revenue.new( pool_id: pool_id,
                      amount: BigDecimal.new( "78.9" ),
                      currency: Revenue::BTC )
    r3.create!

    rs = Revenue.with_pool_id( pool_id )
    expect( rs ).to be_an(Array)
    j_rs = rs.collect { |r| r.to_json }

    [r1, r2, r3].each do |r_orig|
      expect( j_rs.include? r_orig.to_json ).to be true
    end
  end

  it "should convert to JSON" do
    r = valid_revenue
    r.create!

    # verify the fields
    j = JSON.parse( r.to_json )
    expect( j['revenue_id'] ).to be_a String
    expect( j['pool_id'] ).to be_a String
    expect( j['amount'] ).to be_a String
    expect( j['currency'] ).to be_a String
    expect( j['created_at'] ).to be_a String

    # verify the amount is represented as a string
    expect( BigDecimal.new( @string_amount ) ).to eq( BigDecimal.new(j['amount']) )
  end

  it "should enforce allowed currencies" do
    r = Revenue.new( pool_id: @pool_id,
                     amount: BigDecimal.new("1.2345"),
                     currency: "NOP" )
    expect(r.valid?).to be false
    expect(r.errors.include? Revenue::UNKNOWN_CURRENCY_ERROR ).to be true
  end

  it "should enforce amounts as BigDecimal" do
    r = Revenue.new( pool_id: @pool_id,
                     amount: 1.2345,
                     currency: Revenue::BTC )
    expect(r.valid?).to be false
    expect(r.errors.include? Revenue::AMOUNT_TYPE_ERROR ).to be true
  end
  
end

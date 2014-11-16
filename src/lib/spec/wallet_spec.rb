require_relative 'helper'
require_relative '../wallet'

describe Wallet do

  def valid_wallet
    Wallet.new(relation_id: App.unique_id,
               kind: Wallet::ORIGIN_KIND,
               currency: Wallet::BTC_CURRENCY,
               identifier: App.unique_id)
  end

  before(:each) do
    App.db[:wallets].delete
  end
  
  it "should validate all fields" do
    w = Wallet.new()
    expect( w.valid? ).to be false
    expect( w.errors ).to be_an(Array)
    expect( w.errors.length ).to eq(4)

    expect( valid_wallet.valid? ).to be true
  end
  
  it "should save and load" do
    w = valid_wallet
    expect( w.save! ).to_not be false

    s = Wallet.get( w.wallet_id )
    expect(s.wallet_id).to eq(w.wallet_id)
    expect(s.created_at.to_s).to eq(w.created_at.to_s)
    expect(s.relation_id).to eq(w.relation_id)
    expect(s.kind).to eq(w.kind)
    expect(s.currency).to eq(w.currency)
    expect(s.identifier).to eq(w.identifier)
  end

  it "should find by kind and identifier" do
    w = valid_wallet
    w.save!

    s = Wallet.with_kind_identifier( w.kind, w.identifier )
    expect( s.to_json ).to eq(w.to_json)
  end

  it "should find by kind and currency" do
    w = valid_wallet
    w.save!
    s = Wallet.with_kind_currency( w.kind, w.currency )
    expect( s.to_json ).to eq( w.to_json )
  end
  
end

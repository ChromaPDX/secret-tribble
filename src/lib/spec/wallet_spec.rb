require_relative 'helper'
require_relative '../wallet'

describe Wallet do

  def valid_wallet
    Wallet.new(account_id: App.unique_id,
               kind: Wallet::ORIGIN_KIND,
               currency: Wallet::BITCOIN_CURRENCY,
               identifier: App.unique_id)
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
    expect(s.account_id).to eq(w.account_id)
    expect(s.kind).to eq(w.kind)
    expect(s.currency).to eq(w.currency)
    expect(s.identifier).to eq(w.identifier)
  end

end

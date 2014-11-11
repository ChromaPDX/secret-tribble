require 'json'

class Wallet

  ORIGIN_KIND = "ORIGIN" # Origin wallets are the original source of income (eg: iTunes)
  REVENUE_KIND = "REVENUE" # Revenue wallets are where money from an origin is deposited
  BACKER_KIND = "BACKER" # Backer wallets contain the royalties distributed from Revenue
  KINDS = [ORIGIN_KIND, REVENUE_KIND, BACKER_KIND]

  BITCOIN_CURRENCY = "BTC"
  CURRENCIES = [BITCOIN_CURRENCY]
  
  attr_reader :wallet_id, :account_id, :created_at, :kind, :currency, :identifier, :errors
  
  def initialize( opts = {} )
    @wallet_id = opts[:wallet_id]
    @account_id = opts[:account_id]
    @created_at = opts[:created_at]
    @kind = opts[:kind]
    @currency = opts[:currency]
    @identifier = opts[:identifier]
    @errors = []
  end

  def valid?
    @errors = []

    @errors << "account_id must be present" unless @account_id

    @errors << "kind must be one of #{KINDS.join(', ')}" unless KINDS.include? @kind

    @errors << "currency must be one of #{CURRENCIES.join(', ')}" unless CURRENCIES.include? @currency

    @errors << "identifier must be present" unless @identifier

    @errors.empty?
  end

  def save!
    return false unless valid?

    @created_at = Time.now
    @wallet_id = App.unique_id
    
    ws = App.db[:wallets]
    ws.insert(wallet_id: @wallet_id,
              created_at: @created_at,
              account_id: @account_id,
              kind: @kind,
              currency: @currency,
              identifier: @identifier)

    true
  end

  def to_json
    {
      wallet_id: @wallet_id,
      created_at: @created_at,
      account_id: @account_id,
      kind: @kind,
      currency: @currency,
      identifier: @identifier
    }
      .delete_if { |k,v| v.nil? }
      .to_json
  end

  def self.rehydrate( rec )
    Wallet.new( rec )
  end
  
  def self.get( wallet_id )
    rehydrate( App.db[:wallets][wallet_id: wallet_id] )
  end
end

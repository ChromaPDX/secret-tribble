class Ledger

  def initialize( opts )
    @to_wallet_id = opts[:to_wallet_id]
    @from_wallet_id = opts[:from_wallet_id]
    @amount = opts[:amount]
    @pool_id = opts[:pool_id]
    @project_id = opts[:project_id]
    @origin = opts[:origin]
    @transaction_id = opts[:transaction_id]
    @created_at = opts[:created_at]
  end

  def save!
    @ledger_id = App.unique_id
    @created_at = Time.now
    App.db[:ledger].insert( ledger_id: @ledger_id,
                            created_at: @created_at,
                            to_wallet_id: @to_wallet_id,
                            from_wallet_id: @from_wallet_id,
                            amount: @amount,
                            pool_id: @pool_id,
                            project_id: @project_id,
                            origin: @origin_id,
                            transaction_id: @transaction_id
                          )
    true
  end

  def to_json( opts = {} )
    { ledger_id: @ledger_id,
      created_at: @created_at,
      to_wallet_id: @to_wallet_id,
      from_wallet_id: @from_wallet_id,
      amount: "%.4f" % @amount,
      pool_id: @pool_id,
      project_id: @project_id,
      origin: @origin_id,
      transaction_id: @transaction_id
    }
      .delete_if { |k,v| v.nil? }
      .to_json( opts )
  end
  
  def self.rehydrate( r )
    Ledger.new( r )
  end
  
  def self.to_wallet( wallet_id )
    ls = App.db[:ledger].where(to_wallet_id: wallet_id)
    ls.map { |l| rehydrate l }
  end
  
end

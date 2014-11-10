class Revenue

  attr_reader :revenue_id, :pool_id, :amount, :currency, :created_at, :errors

  BTC = "BTC"
  CURRENCIES = [BTC]

  UNKNOWN_CURRENCY_ERROR = "Unknown currency type."
  AMOUNT_TYPE_ERROR = "Revenue amount must be a BigDecimal."

  USER_POOL_QUERY = "SELECT revenue.* FROM revenue, pools WHERE revenue.pool_id=pools.pool_id AND pools.user_id=? AND pools.pool_id=?"
  
  def initialize( opts = {} )
    @revenue_id = opts[:revenue_id]
    @pool_id = opts[:pool_id]
    @amount = opts[:amount]
    @currency = opts[:currency]
    @created_at = opts[:created_at]
    @errors = []
  end

  
  def to_json( opts = {} )
    {
      revenue_id: @revenue_id,
      pool_id: @pool_id,
      amount: ("%.5f" % @amount),
      currency: @currency,
      created_at: @created_at
    }
      .delete_if { |k,v| v.nil? }
      .to_json( opts )
  end

  
  def create!
    return false unless valid?
    
    rev = App.db[:revenue]
    @created_at = Time.now
    @revenue_id = App.unique_id
    rev.insert( revenue_id: @revenue_id,
                pool_id: @pool_id,
                amount: @amount,
                currency: @currency,
                created_at: @created_at )
  end

  
  def self.rehydrate( r )
    Revenue.new( revenue_id: r[:revenue_id],
                 pool_id: r[:pool_id],
                 amount: r[:amount],
                 currency: r[:currency],
                 created_at: r[:created_at] )
  end

  
  def self.with_revenue_id( revenue_id )
    result = App.db[:revenue][revenue_id: revenue_id]
    if result
      return rehydrate( result )
    end
    
    false
  end

  def self.with_pool_id( pool_id )
    results = App.db[:revenue].where(pool_id: pool_id)
    results.collect { |r| rehydrate(r) }
  end

  def self.with_user_pool( user_id, pool_id )
    rs = App.db.fetch(USER_POOL_QUERY, user_id, pool_id)
    rs.collect { |r| rehydrate(r) }
  end


  def valid?
    @errors = []
    @errors << AMOUNT_TYPE_ERROR unless @amount.is_a? BigDecimal
    @errors << UNKNOWN_CURRENCY_ERROR unless CURRENCIES.include? @currency
    @errors.empty?
  end
end

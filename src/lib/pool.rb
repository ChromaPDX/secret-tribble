require 'json'
require_relative 'app'

class Pool

  attr_reader :errors, :pool_id, :splits, :created_at
  
  # This is going to require some optimization I expect. The goal is to load the
  # most recent pool definition.
  LOAD_QUERY = "SELECT * FROM pools WHERE pool_id=? AND created_at=(SELECT max(created_at) FROM pools WHERE pool_id=? AND created_at<=?)"

  # Error strings
  BAD_ACCOUNT_ERROR  = "Account ID is not a valid ID"
  PCT_TYPE_ERROR     = "Split value must be a BigDecimal"
  TOTAL_SPLIT_ERROR  = "Total value of splits must equal 1.0"
  PCT_RANGE_ERROR  = "Split must be between 0.0 and 1.0"
  
  def initialize( pool_id = nil )
    @pool_id = pool_id || App.unique_id
    @splits = {}
    @errors = []
    @created_at = nil
  end
  

  def split!( account_id, pct )
    if pct.nil? or pct == 0
      @splits.delete(account_id)
    else
      @splits[account_id] = pct
    end
  end


  def distribute( amount )
    Hash[ @splits.map { |k,v| [k, v * amount] } ]
  end

  
  # save will not *update*; this is an append only table!
  def save
    pools = App.db[:pools]
    @created_at = Time.now # uniform created_at dates for all of the splits.

    # return a list of pool_ids for the new pools
    @splits.collect do |account_id, split_pct|
      pools.insert( pool_id: @pool_id,
                    account_id: account_id,
                    split_pct: split_pct,
                    created_at: @created_at)
    end
  end


  def to_json
    {
      created_at: @created_at,
      pool_id: @pool_id,
      splits: Hash[ @splits.collect { |account_id, split_pct| [account_id, "%.4f" % split_pct] } ]
    }
      .delete_if { |k,v| v.nil? }
      .to_json
  end

  
  def load!( ts = Time.now )
    pools = App.db.fetch(LOAD_QUERY, @pool_id, @pool_id, ts)
    return false if pools.empty?
    
    pools.each do |d|
      @splits[ d[:account_id] ] = d[:split_pct]
    end
    
    @created_at = pools.first[:created_at]
    
    true
  end

  
  def valid?
    @errors = []

    # validate individual split keys and values
    @splits.each do |k,v|
      @errors << BAD_ACCOUNT_ERROR unless k.is_a? String
      @errors << PCT_TYPE_ERROR unless v.is_a? BigDecimal
      @errors << PCT_RANGE_ERROR unless (v >= BigDecimal.new("0.0") and v <= BigDecimal.new("1.0"))
    end

    # validate that the total split is 1.0
    total = @splits.collect { |k, v| v }.reduce :+
    if total != BigDecimal.new("1.0")
      @errors << TOTAL_SPLIT_ERROR
    end
    
    @errors.empty?
  end

end

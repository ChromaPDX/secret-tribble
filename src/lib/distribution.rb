require 'json'
require_relative 'app'

class Distribution

  # This is going to require some optimization I expect. The goal is to load the
  # most recent set of distributions.
  LOAD_QUERY = "SELECT * FROM DISTRIBUTIONS WHERE pool_id=? AND created_at=(SELECT max(created_at) FROM distributions WHERE pool_id=? AND created_at<=?)"

  # Error strings
  BAD_ACCOUNT_ERROR  = "Account ID is not a valid ID"
  PCT_TYPE_ERROR     = "Split value must be a BigDecimal"
  TOTAL_SPLIT_ERROR  = "Total value of splits must equal 1.0"
  PCT_RANGE_ERROR  = "Split must be between 0.0 and 1.0"
  
  def initialize( pool_id )
    @pool_id = pool_id
    @splits = {}
    @errors = []
  end
  

  def pool_id
    @pool_id
  end


  def splits
    @splits
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
    distributions = App.db[:distributions]
    timestamp = Time.now # uniform created_at dates for all of the splits.

    # return a list of distribution_ids for the new distributions
    @splits.collect do |account_id, split_pct|
      distributions.insert( distribution_id: App.unique_id,
                            pool_id: @pool_id,
                            account_id: account_id,
                            split_pct: split_pct,
                            created_at: timestamp)
    end
  end


  def load!( ts = Time.now )
    distributions = App.db.fetch(LOAD_QUERY, @pool_id, @pool_id, ts)
    distributions.each do |d|
      @splits[ d[:account_id] ] = d[:split_pct]
    end
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

  def errors
    @errors
  end
  
end

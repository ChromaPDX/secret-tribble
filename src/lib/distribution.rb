require 'json'
require_relative 'app'

class Distribution

  # This is going to require some optimization I expect. The goal is to load the
  # most recent set of distributions.
  LOAD_QUERY = "SELECT * FROM DISTRIBUTIONS WHERE pool_id=? AND created_at=(SELECT max(created_at) FROM distributions WHERE pool_id=?)"
  
  def initialize( pool_id, output_dir = nil )
    @pool_id = pool_id
    @splits = {}
    @output_dir = output_dir
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


  def load!
    distributions = App.db.fetch(LOAD_QUERY, @pool_id, @pool_id)
    distributions.each do |d|
      @splits[ d[:account_id] ] = d[:split_pct]
    end
    true
  end

end

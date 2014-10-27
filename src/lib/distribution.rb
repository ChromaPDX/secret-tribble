require 'json'
require_relative 'app'

class Distribution

  CREATE_QUERY = "CREATE TABLE IF NOT EXISTS %s (id BIGSERIAL PRIMARY KEY, pool_id VARCHAR(32) NOT NULL, asset_id VARCHAR(32) NOT NULL, account_id VARCHAR(32) NOT NULL, split_pct INT NOT NULL)"
  INSERT_QUERY = ""
    
  def self.setup!
      
  end
    
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


  def split!( key, value )
    if value.nil? or value == 0
      @splits.delete(key)
    else
      @splits[key] = value
    end
  end


  def distribute( amount )
    Hash[ @splits.map { |k,v| [k, v * amount] } ]
  end


  def file_path
    File.join( @output_dir, "#{@pool_id}.json" )
  end


  def save
    File.open( file_path, "w" ) { |f| f.write( @splits.to_json ) }
    true
  end


  def load!
    File.open( file_path, "r" ) { |f| @splits = JSON.load(f) }
    true
  end

end

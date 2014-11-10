require 'json'
require_relative 'pool'

class Project

  attr_reader :project_id, :pool_id, :name, :created_at, :backers

  
  def initialize( opts = {} )
    @project_id = opts[:project_id]
    @pool_id = opts[:pool_id]
    @name = opts[:name]
    @created_at = opts[:created_at]
    @backers = {}
  end

  
  def set_pool( pool_id )
    @pool_id = pool_id
  end

  
  def save!
    @project_id ||= App.unique_id
    @created_at ||= Time.now

    db.insert( project_id: @project_id,
               pool_id: @pool_id,
               name: @name,
               created_at: @created_at )
  end


  def with_backers!
    p = Pool.new( @pool_id )
    p.load!
    @backers = p.splits
  end
  
  
  def db
    App.db[:projects]
  end

  
  def to_json
    j = {
      project_id: @project_id,
      pool_id: @pool_id,
      name: @name,
      created_at: @created_at
    }
    j[:backers] = Hash[@backers.map { |k,v| [k, "%.4f" % v] }] unless @backers.empty?
    
    j.delete_if { |k,v| v.nil? }.to_json
  end

  
  def self.get( project_id )
    Project.new( App.db[:projects][project_id: project_id] )
  end
  
end

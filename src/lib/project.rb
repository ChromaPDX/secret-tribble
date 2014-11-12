require 'json'
require_relative 'pool'

class Project

  attr_reader :project_id, :pool_id, :name, :created_at

  
  def initialize( opts = {} )
    @project_id = opts[:project_id]
    @pool_id = opts[:pool_id]
    @name = opts[:name]
    @created_at = opts[:created_at]
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


  def db
    App.db[:projects]
  end

  
  def to_json
    {
      project_id: @project_id,
      pool_id: @pool_id,
      name: @name,
      created_at: @created_at
    }
      .delete_if { |k,v| v.nil? }
      .to_json
  end

  
  def self.get( project_id )
    p = App.db[:projects][project_id: project_id]
    return false if p.nil?
    
    Project.new( p )
  end
  
end

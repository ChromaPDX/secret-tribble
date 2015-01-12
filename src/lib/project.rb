require 'json'
require_relative 'pool'

class Project

  attr_reader :project_id, :pool_id, :name, :created_at

  WITH_USER_QUERY = "SELECT DISTINCT projects.* FROM projects, pools WHERE projects.pool_id=pools.pool_id AND pools.user_id=?"
  WITH_OWNER_QUERY = "SELECT DISTINCT projects.* FROM projects WHERE projects.user_id=?"
  
  def initialize( opts = {} )
    @project_id = opts[:project_id]
    @pool_id = opts[:pool_id]
    @user_id = opts[:user_id]
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
               user_id: @user_id,
               name: @name,
               created_at: @created_at )
  end


  def db
    App.db[:projects]
  end

  
  def to_json( opts = {} )
    {
      project_id: @project_id,
      pool_id: @pool_id,
      user_id: @user_id,
      name: @name,
      created_at: @created_at
    }
      .delete_if { |k,v| v.nil? }
      .to_json( opts )
  end

  
  def self.get( project_id )
    p = App.db[:projects][project_id: project_id]
    return false if p.nil?
    
    Project.new( p )
  end

  def self.with_user( user_id )
    projects = App.db.fetch(WITH_USER_QUERY, user_id)
    projects.map { |p| Project.new(p) }
  end

  def self.with_owner( user_id )
    projects = App.db.fetch(WITH_OWNER_QUERY, user_id)
    projects.map { |p| Project.new(p) }
  end
  
end

require 'json'
require_relative 'app'

class Token

  MISSING_USER_ID_ERROR = "user_id is a required attribute"

  attr_reader :token_id, :user_id, :created_at, :metadata, :errors
  
  def initialize( opts = {} )
    @token_id = opts[:token_id]
    @user_id = opts[:user_id]
    @created_at = opts[:created_at]
    @metadata = opts[:metadata]
    @errors = []
  end

  
  def self.create!( user_id, metadata = nil )
    @user_id = user_id
    @metadata = metadata
    @token_id = App.unique_id
    @created_at = Time.now
    
    tokens = App.db[:tokens]
    tokens.insert( token_id: @token_id,
                   user_id: @user_id,
                   metadata: @metadata,
                   created_at: @created_at
                 )
    
    self.get( @token_id )
  end

  
  def self.all_for( user_id )
    raw_tokens = App.db[:tokens].filter( user_id: user_id )
    raw_tokens.collect { |rt| rehydrate( rt ) }
  end
  
  
  def to_json( opt = nil )
    {
      token_id: @token_id,
      user_id: @user_id,
      metadata: @metadata,
      created_at: @created_at
    }
      .delete_if { |k,v| v.nil? }
      .to_json
  end

  def self.rehydrate( result )
    Token.new( token_id: result[:token_id],
               user_id: result[:user_id],
               created_at: result[:created_at],
               metadata: result[:metadata] )
  end
  
  
  def self.get( token_id )
    raw = App.db[:tokens][token_id: token_id]
    return false if raw.nil?

    rehydrate(raw)
  end

  def delete!
    App.db[:tokens].where(token_id: @token_id).delete
  end

  
  def valid?
    @errors << MISSING_USER_ID_ERROR if @user_id.nil?
    @errors.empty?
  end

  
  def errors
    @errors
  end
  
end

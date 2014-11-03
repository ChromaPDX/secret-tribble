require 'json'
require_relative 'app'

class Token

  MISSING_ACCOUNT_ID_ERROR = "account_id is a required attribute"

  attr_reader :token_id, :account_id, :created_at, :metadata, :errors
  
  def initialize( opts = {} )
    @token_id = opts[:token_id]
    @account_id = opts[:account_id]
    @created_at = opts[:created_at]
    @metadata = opts[:metadata]
    @errors = []
  end

  
  def self.create!( account_id, metadata = nil )
    @account_id = account_id
    @metadata = metadata
    @token_id = App.unique_id
    @created_at = Time.now
    
    tokens = App.db[:tokens]
    tokens.insert( token_id: @token_id,
                   account_id: @account_id,
                   metadata: @metadata,
                   created_at: @created_at
                 )
    
    self.get( @token_id )
  end

  def self.all_for( account_id )
    raw_tokens = App.db[:tokens].filter( account_id: account_id )
    raw_tokens.collect { |rt| rehydrate( rt ) }
  end
  
  
  def to_json
    {
      token_id: @token_id,
      account_id: @account_id,
      metadata: @metadata,
      created_at: @created_at
    }
      .delete_if { |k,v| v.nil? }
      .to_json
  end

  def self.rehydrate( result )
    Token.new( token_id: result[:token_id],
               account_id: result[:account_id],
               created_at: result[:created_at],
               metadata: result[:metadata] )
  end
  
  
  def self.get( token_id )
    raw = App.db[:tokens][token_id: token_id]
    return false if raw.nil?

    rehydrate(raw)
  end

  
  def valid?
    @errors << MISSING_ACCOUNT_ID_ERROR if @account_id.nil?
    @errors.empty?
  end

  
  def errors
    @errors
  end
  
end

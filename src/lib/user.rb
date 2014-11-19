require 'json'
require 'bcrypt'

require_relative 'app'

class User

  attr_reader :name, :user_id, :created_at

  PASSWORD_CREDENTIAL_KIND   = "PASSWORD"
  SECRET_KEY_CREDENTIAL_KIND = "SECRET_KEY"

  
  def initialize( opts = {} )
    @user_id = opts[:user_id]
    @name = opts[:name]
    @created_at = opts[:created_at]
    @errors = []
  end

  
  def to_json
    {
      user_id: @user_id,
      name: @name,
      created_at: @created_at
    }.to_json
  end

  
  def self.create!( name )
    @user_id = App.unique_id
    @name = name
    @created_at = Time.now

    users = App.db[:users]
    users.insert( user_id: @user_id,
                  name: @name,
                  created_at: @created_at )
    
    self.get( @user_id )
  end

  
  def self.get( user_id )
    raw = App.db[:users][user_id: user_id]
    return false if raw.nil?

    rehydrate( raw )
  end

  
  def self.rehydrate( result )
    User.new( user_id: result[:user_id],
              name: result[:name],
              created_at: result[:created_at] )
  end


  def self.salted_string( string, salt )
    string + salt
  end

  
  def self.hash_string( string, salt )
    BCrypt::Password.create( salted_string( string, salt ) )
  end

  
  def set_encrypted_kind( kind, cleartext, identifier = nil )
    creds = App.db[:credentials]
    salt = App.unique_id

    begin
      App.db.transaction do
        # all or nothing process for updating a user's credentials. generally speaking,
        # there's a unique index on 'kind' and 'identifier' which cannot be violated.
        # the transaction will automatically rollback if the database throws an exception.
        
        # delete any existing credentials of this type for this user
        creds.where(kind: kind,
                    user_id: @user_id).delete
        
        # create a new credential for the user
        creds.insert(kind: kind,
                     user_id: @user_id,
                     salt: salt,
                     identifier: identifier,
                     password_digest: User.hash_string( cleartext, salt ),
                     created_at: Time.now )
        return true
      end
    rescue => e
      # catch the exception re-raised by Sequel
    end

    return false
  end

  
  def set_username_pass( username, password )
    set_encrypted_kind( PASSWORD_CREDENTIAL_KIND, password, username )
  end

  
  def set_secret_key( key )
    set_encrypted_kind( SECRET_KEY_CREDENTIAL_KIND, key )
  end
  
  def self.with_secret_key( user_id, cleartext )
    creds = App.db[:credentials]

    # see if we can find a password record for that user
    c = creds[user_id: user_id,
              kind: SECRET_KEY_CREDENTIAL_KIND]
    return false if c.nil?

    # see if passwords match
    target = salted_string( cleartext, c[:salt] )
    checker = BCrypt::Password.new( c[:password_digest] )
    return false unless checker == target

    # load the associated user!
    get( user_id )
  end

  
  def self.with_username_pass( identifier, password )
    creds = App.db[:credentials]

    # see if we can find a password record for that user
    c = creds[identifier: identifier,
              kind: PASSWORD_CREDENTIAL_KIND]
    return false if c.nil?

    # see if passwords match
    target = salted_string( password, c[:salt] )
    checker = BCrypt::Password.new( c[:password_digest] )
    return false unless checker == target

    # load the associated user!
    get( c[:user_id] )
  end

end

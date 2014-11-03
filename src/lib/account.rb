require 'json'
require 'bcrypt'

require_relative 'app'

class Account

  attr_reader :name, :account_id, :created_at

  PASSWORD_CREDENTIAL_KIND   = "PASSWORD"
  SECRET_KEY_CREDENTIAL_KIND = "SECRET_KEY"

  
  def initialize( opts = {} )
    @account_id = opts[:account_id]
    @name = opts[:name]
    @errors = []
  end

  
  def self.create!( name )
    @account_id = App.unique_id
    @name = name
    @created_at = Time.now

    accounts = App.db[:accounts]
    accounts.insert( account_id: @account_id,
                     name: @name,
                     created_at: @created_at )

    self.get( @account_id )
  end

  
  def self.get( account_id )
    raw = App.db[:accounts][account_id: account_id]
    return false if raw.nil?

    rehydrate( raw )
  end

  
  def self.rehydrate( result )
    Account.new( account_id: result[:account_id],
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
    
    # delete any existing credentials of this type for this account
    creds.where(kind: kind,
                account_id: @account_id).delete
    
    # create a new credential for the account
    creds.insert(kind: kind,
                 account_id: @account_id,
                 salt: salt,
                 identifier: identifier,
                 password_digest: Account.hash_string( cleartext, salt ),
                 created_at: Time.now )
  end

  
  def set_user_pass( user, password )
    set_encrypted_kind( PASSWORD_CREDENTIAL_KIND, password, user )
  end

  
  def set_secret_key( key )
    set_encrypted_kind( SECRET_KEY_CREDENTIAL_KIND, key )
  end
  
  def self.with_secret_key( account_id, cleartext )
    creds = App.db[:credentials]

    # see if we can find a password record for that account
    c = creds[account_id: account_id,
              kind: SECRET_KEY_CREDENTIAL_KIND]
    return false if c.nil?

    # see if passwords match
    target = salted_string( cleartext, c[:salt] )
    checker = BCrypt::Password.new( c[:password_digest] )
    return false unless checker == target

    # load the associated account!
    get( account_id )
  end

  
  def self.with_user_pass( identifier, password )
    creds = App.db[:credentials]

    # see if we can find a password record for that account
    c = creds[identifier: identifier,
              kind: PASSWORD_CREDENTIAL_KIND]
    return false if c.nil?

    # see if passwords match
    target = salted_string( password, c[:salt] )
    checker = BCrypt::Password.new( c[:password_digest] )
    return false unless checker == target

    # load the associated account!
    get( c[:account_id] )
  end

end

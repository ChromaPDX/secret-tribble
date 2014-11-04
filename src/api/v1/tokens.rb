require_relative '../../lib/token'

def token_present?
  !params[:token_id].nil?
end


def secret_auth_present?
  params[:account_id] and params[:secret_key]
end


def require_secret_key!
  return false unless secret_auth_present?
  
  @account = Account.with_secret_key( params[:account_id], params[:secret_key] )
  return false unless @account

  true
end


def require_token!
  return false unless token_present?
  
  @token = Token.get( params[:token_id] )
  return false unless @token

  @account = Account.get( @token.account_id )
  return false unless @account

  true
end


def invalid_credentials!
  status 401
  @errors.add "Invalid credentials."
end


doc '/v1/tokens'
get '/v1/tokens.json' do

  # single token check
  if token_present?
    if require_token!
      @out = @token
    else
      invalid_credentials!
    end
    return
  end

  # list of tokens for an account
  if secret_auth_present?
    if require_secret_key!
      ts = Token.all_for( @account.account_id )
      @out = { tokens: ts }
    else
      invalid_credentials!
    end
    return
  end

  invalid_credentials!
end

post '/v1/tokens.json' do
  if require_secret_key!
    token = Token.create!( @account.account_id )
    @out = token
    return
  end
  
  invalid_credentials!
end

delete '/v1/tokens.json' do
  not_implemented
end

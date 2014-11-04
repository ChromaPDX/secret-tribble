require_relative '../../lib/token'

doc '/v1/tokens'


# HEAD checks validity of an existing token.
head '/v1/tokens.json' do

  # single token check
  if token_present?
    if require_token!
      @out = @token
    else
      invalid_credentials!
    end
    return
  end

  invalid_credentials
end


# GET returns all of the tokens for an account.
get '/v1/tokens.json' do
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


# POST creates a token.
post '/v1/tokens.json' do
  if require_secret_key!
    token = Token.create!( @account.account_id )
    @out = token
    return
  end
  
  invalid_credentials!
end


# DELETE removes a token.
delete '/v1/tokens.json' do
  if require_secret_key! and require_token!
    @token.delete!
    @out = @token
    return
  end

  invalid_credentials!
end

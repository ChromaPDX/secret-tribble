require_relative '../../lib/token'


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

require_relative '../../lib/token'

doc '/v1/tokens'
get '/v1/tokens.json' do
  t = Token.get( params[:token_id] )
  if t
    @out = t
  else
    status 404
    @errors.add "Invalid token."
  end
end

post '/v1/tokens.json' do
  not_implemented
end

delete '/v1/tokens.json' do
  not_implemented
end

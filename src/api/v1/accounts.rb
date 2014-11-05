doc "/v1/accounts"

get "/v1/accounts.json" do
  if require_token!
    @out = @account
    return
  else
    invalid_credentials!
  end
end

post "/v1/accounts.json" do
  user     = params[:user]
  password = params[:password]

  if user and password
    account = Account.with_user_pass( user, password )
    if account
      @out = Token.create!( account.account_id )
      return
    end
  end

  invalid_credentials!
end

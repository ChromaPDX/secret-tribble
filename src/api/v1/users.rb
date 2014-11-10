doc "/v1/users"

get "/v1/users.json" do
  if require_token!
    @out = @user
    return
  else
    invalid_credentials!
  end
end

post "/v1/users.json" do
  username = params[:username]
  password = params[:password]

  if username and password
    user = User.with_username_pass( username, password )
    if user
      @out = Token.create!( user.user_id )
      return
    end
  end

  invalid_credentials!
end

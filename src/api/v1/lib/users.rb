doc "/v1/users"

get "/v1/users.json" do
  if require_token!
    user_id = params[:user_id]

    if user_id
      @out = User.get( user_id )
      return
    else
      @out = @user
      return
    end
  end

  invalid_credentials!
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

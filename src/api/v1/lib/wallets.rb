require_relative '../../../lib/wallet'

doc '/v1/wallets'

get '/v1/wallets.json' do
  unless require_token!
    invalid_credentials!
    return
  end

  # singular wallet by wallet_id
  wallet_id = params[:wallet_id]
  if wallet_id
    wallet = Wallet.get( wallet_id )
  
    unless wallet
      status 404
      @errors.add("No wallet found with wallet_id #{wallet_id}")
      return
    end
    @out = wallet
    return
  end

  # singular wallet by relation_id
  relation_id = params[:relation_id]
  if relation_id
    wallet = Wallet.with_relation( relation_id )
  
    unless wallet
      status 404
      @errors.add("No wallet found with relation_id #{relation_id}")
      return
    end
    @out = wallet
    return
  end

  
  # multiple wallets
  @out = Wallet.with_user( @user.user_id )
end

get '/v1/wallets/search.json' do
  unless require_service_token!
    invalid_credentials!
    return
  end

  kind = params[:kind]
  identifier = params[:identifier]

  unless kind and identifier
    @errors.add("Please specify a kind and identifier")
    return
  end

  wallet = Wallet.with_kind_identifier( kind, identifier )

  unless wallet
    status 404
    @errors.add("No wallet found.")
    return
  end

  @out = wallet
end

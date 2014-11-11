require_relative '../../../lib/wallet'

doc '/v1/wallets'

get '/v1/wallets.json' do
  unless require_token!
    invalid_credentials!
    return
  end
  
  wallet_id = params[:wallet_id]
  
  unless wallet_id
    @errors.add("Please provide a wallet_id.")
    return
  end
  
  wallet = Wallet.get( wallet_id )
  
  unless wallet
    status 404
    @errors.add("No wallet found with wallet_id #{wallet_id}")
    return
  end

  @out = wallet
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

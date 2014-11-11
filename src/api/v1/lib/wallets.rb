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


require_relative '../../../lib/wallet'

doc '/v1/wallets'

get '/v1/wallets.json' do
  if require_token!
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
    return
  end

  invalid_credentials!
end

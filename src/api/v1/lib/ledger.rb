require_relative '../../../lib/ledger'

doc '/v1/ledger'

get '/v1/ledger.json' do
  unless require_token!
    invalid_credentials!
    return
  end

  # singular ledger by to_wallet_id
  to_wallet_id = params[:to_wallet_id]
  if to_wallet_id
    ledger = Ledger.to_wallet( to_wallet_id )
  
    unless ledger
      status 404
      @errors.add("No ledger found with to_wallet_id #{to_wallet_id}")
      return
    end
    @out = ledger
    return
  end

  @errors.add("Please specify ledger_id, or to_wallet_id")
end

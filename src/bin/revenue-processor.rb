require_relative "../lib/app"

POLLING_DELAY = 5 # seconds

App.configure! ENV['CHROMA_ENV']

revenue_queue = PersistentQueue.new("revenue_transactions")
distribution_queue = PersistentQueue.new("distribution_transactions")

while true
  while revenue_queue.size == 0
    puts "Sleeping ..."
    sleep POLLING_DELAY
  end

  revenue_queue.pop do |msg|
    puts "Received message: #{msg.inspect}"
    
    body = msg[:body]
    pool_id = body['pool_id']
    amount = BigDecimal.new( body['amount'] )

    # first, enter this as revenue in the ledger for the appropriate wallet
    origin_wallet = Wallet.with_kind_currency( Wallet::ORIGIN_KIND, body['currency'] )
    puts "Origin wallet: #{origin_wallet.inspect}"

    revenue_wallet = Wallet.get( body['wallet_id'] )
    puts "Revenue wallet: #{revenue_wallet.inspect}"
    
    ledger_entry = Ledger.new( to_wallet_id: revenue_wallet.wallet_id,
                               from_wallet_id: origin_wallet.wallet_id,
                               amount: "%.4f" % amount,
                               pool_id: pool_id,
                               project_id: body['project_id'],
                               origin: body['origin'].to_json,
                               transaction_id: body['transaction_id'] )
    ledger_entry.save!
    puts "Ledger entry: #{ledger_entry.inspect}"
    
    # second, create the distribution messages
    pool = Pool.new( pool_id )
    pool.load!
    puts "Pool: #{pool.inspect}"

    distributions = pool.distribute( amount )
    puts "Distributions: #{distributions.inspect}"

    distributions.each do |user_id, amount|
      # use the original message as the base message
      # - adding the user_id
      # - update the amount
      # - delete the wallet_id
      new_msg = body.clone
      new_msg['user_id'] = user_id
      new_msg['amount'] = "%.4f" % amount
      new_msg.delete 'wallet_id'
      puts "Distribution Message: #{new_msg.inspect}"
      distribution_queue.push( new_msg )
    end
    
  end

end

require_relative "../lib/app"

POLLING_DELAY = 5 # seconds

App.configure! ENV['CHROMA_ENV']

distribution_queue = PersistentQueue.new("distribution_transactions")

while true
  while distribution_queue.size == 0
    puts "Sleeping ..."
    sleep POLLING_DELAY
  end
  
  distribution_queue.pop do |msg|
    puts "Received message: #{msg.inspect}"
    
    body = msg[:body]
    pool_id = body['pool_id']
    amount = BigDecimal.new( body['amount'] )

    # first, enter this as revenue in the ledger for the appropriate wallet
    project_wallet = Wallet.with_kind_currency_relation( Wallet::REVENUE_KIND, body['currency'], body['project_id'] )
    puts "Project wallet: #{project_wallet.inspect}"

    backer_wallet = Wallet.with_kind_currency_relation( Wallet::BACKER_KIND, body['currency'], body['user_id'] )
    puts "Backer wallet: #{backer_wallet.inspect}"

    # create the ledger entry
    ledger_entry = Ledger.new( to_wallet_id: backer_wallet.wallet_id,
                               from_wallet_id: project_wallet.wallet_id,
                               amount: "%.4f" % amount,
                               pool_id: pool_id,
                               project_id: body['project_id'],
                               origin: body['origin'].to_json,
                               transaction_id: body['transaction_id'] )
    ledger_entry.save!
    puts "Ledger entry: #{ledger_entry.inspect}"

    # distribute the bitcoin, yo
  end
end

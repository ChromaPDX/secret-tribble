require 'faye/websocket'
require 'eventmachine'
require 'json'

require_relative 'persistent_queue'
require_relative 'wallet'
require_relative 'pool'
require_relative 'project'

class TransactionStream

  BLOCKCHAIN_INFO_WS = "wss://ws.blockchain.info/inv"
  
  def collect
    transaction_queue = PersistentQueue.new( "raw_btc_transactions" )
    
    EM.run {
      ws = Faye::WebSocket::Client.new( BLOCKCHAIN_INFO_WS )

      ws.on :error do |event|
        p ws.inspect
      end
      
      ws.on :open do |event|
        p [:open]
        # ws.send('{"op":"blocks_sub"}')
        ws.send('{"op":"unconfirmed_sub"}')
      end

      ws.on :message do |event|
        # CURRENTLY IMPLEMENTED AS DIRECT TO DB; RUN ME THROUGH THE API!
        btc_outputs = event['x']['out']
        btc_outputs.each do |o|
          identifier = o['addr']
          satoshis   = o['value']

          wallet = Wallet.with_kind_identifier( Wallet::REVENUE_KIND, identifier )

          if wallet
            pool = Pool.get( wallet.relation_id )
            project = Project.with_pool( pool.pool_id )
          end

          next unless wallet and pool and project

          transaction_id = App.unique_id
          
          msg = {
            currency: Wallet::BTC_CURRENCY,
            amount: satoshis,
            project_id: project.project_id,
            pool_id: pool.pool_id,
            origin: { name: 'blockchain' },
            transaction_id: transaction_id
          }
          
          transaction_queue.push( msg )
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end

    }
    
  end
  
end

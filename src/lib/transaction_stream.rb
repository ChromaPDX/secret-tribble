require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'logger'

require_relative 'persistent_queue'
require_relative 'wallet'
require_relative 'pool'
require_relative 'project'

class TransactionStream

  BLOCKCHAIN_INFO_WS = "wss://ws.blockchain.info/inv"
  LOG = Logger.new("transaction.log")

  
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
        j = JSON.parse(event.data)        
        hash = j['x']['hash']

        LOG.info "TX - #{hash} - #{event.data}"

        btc_outputs = j['x']['out']
        btc_outputs.each do |o|
          STDOUT.print "."
          STDOUT.flush

          identifier = o['addr']
          satoshis   = o['value']

          LOG.info "OUT - #{hash} - #{identifier} - #{satoshis}"
          
          wallet = Wallet.with_kind_identifier( Wallet::REVENUE_KIND, identifier )
          if wallet

            LOG.info "WALLET - #{hash} - #{wallet.wallet_id}"

            project = Project.get( wallet.relation_id )
            if project

              LOG.info "PROJECT - #{hash} - #{project.project_id}"
              
              pool = Pool.new( project.pool_id )
              if pool.load!
                
                LOG.info "POOL - #{hash} - #{pool.pool_id}"
                
                transaction_id = App.unique_id
                
                msg = {
                  currency: Wallet::BTC_CURRENCY,
                  amount: satoshis,
                  project_id: project.project_id,
                  pool_id: pool.pool_id,
                  origin: { name: 'blockchain' },
                  transaction_id: transaction_id
                }
                
                LOG.info "SUCCESS - #{hash} - #{msg.to_json}"
                
                transaction_queue.push( msg )
              end
            end
          end
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
        EM.stop_event_loop
      end

    }
    
  end
  
end

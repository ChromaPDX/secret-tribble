require 'faye/websocket'
require 'eventmachine'
require 'json'

class TransactionStream

  BLOCKCHAIN_INFO_WS = "wss://ws.blockchain.info/inv"
  
  def collect
    EM.run {
      ws = Faye::WebSocket::Client.new( BLOCKCHAIN_INFO_WS )

      ws.on :error do |event|
        p ws.inspect
      end
      
      ws.on :open do |event|
        p [:open]
        ws.send('{"op":"blocks_sub"}')
        ws.send('{"op":"unconfirmed_sub"}')
      end

      ws.on :message do |event|
        puts event.data
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end

    }
    
  end
  
end

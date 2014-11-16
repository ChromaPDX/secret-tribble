require 'json'

class PersistentQueue

  attr_reader :topic

  POP_QUERY = "DELETE FROM queues WHERE message_id=(SELECT message_id FROM queues WHERE topic=? ORDER BY created_at DESC LIMIT 1) RETURNING *"
  
  def initialize( topic )
    @topic = topic
  end

  def push( msg )
    j = msg.to_json

    @created_at = Time.now
    @message_id = App.unique_id

    out = {
      'topic' => @topic,
      'message_id' => @message_id,
      'created_at' => @created_at,
      'body' => j
    }

    db.insert( out )

    App.log.info("QUEUE - #{@topic} - PUSHED - #{out['message_id']} - #{out['body']}")
    
    # make sure the returned record has the original msg
    out['body'] = msg
    out
  end
  
  def pop( &block )
    begin
      m = App.db.fetch( POP_QUERY, @topic ).first
      return unless m
      
      m[:body] = JSON.parse(m[:body])
      App.log.info("QUEUE - #{@topic} - STARTED - #{m[:message_id]} - #{m[:body].inspect}")
      result = yield m
      App.log.info("QUEUE - #{@topic} - COMPLETED - #{m[:message_id]} - #{result.inspect}") 
    rescue => e
      puts e
      puts e.backtrace
      App.log.error("QUEUE - #{@topic } - ERROR - Exception: #{e}")
    end
  end

  def get( message_id )
    db[message_id: message_id].first
  end

  def clear!
    db.where(topic: @topic).delete
  end

  def size
    db.where(topic: @topic).count
  end

  def db
    App.db[:queues]
  end

end

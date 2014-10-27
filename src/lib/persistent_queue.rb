# BEHAVIOR:
#
# - FIFO
# - Safe for #push from multiple publishers.
# - #pop and #subscribe guarantee one time delivery.
# - Messages are deleted IMMEDIATELY for #pop and #subscribe.
# - If you want to record a failure that won't be reprocessed, use #fail( msg )
# - The methods work with native Ruby objects (strings, arrays, hashes) and (un)marshall via JSON.
# - #subscribe takes a block argument, which it calls every time it receives a message.
#
# Currently implemented on PostgreSQL. Move me to a dedicated queue when it gets slow. :)

require 'json'
require 'pg'

require_relative 'app'

class PersistentQueue

  POLL_DELAY = 5 # seconds
  CREATE_QUEUE_QUERY = "CREATE TABLE IF NOT EXISTS %s (id BIGSERIAL PRIMARY KEY, ts TIMESTAMP DEFAULT current_timestamp NOT NULL, msg JSON NOT NULL)"   
  POP_QUERY = "DELETE FROM %s WHERE id=(SELECT min(id) FROM %s) RETURNING *" # atomic select and delete of the oldest message
  PUSH_QUERY = "INSERT INTO %s (msg) VALUES ('%s')" # id and ts should automatically populate
  
  def initialize( queue_name )
    @connection = App.db_connection

    @name = "queue_" + queue_name
    @quoted_name = @connection.quote_ident(@name)
    
    @fail_name = @name + "_failures"
    @quoted_fail_name = @connection.quote_ident(@name)
   
    # create the queue if it doesn't already exist
    @connection.exec( CREATE_QUEUE_QUERY % @quoted_name )

    # create the failed message queue if it doesn't already exist
    @connection.exec( CREATE_QUEUE_QUERY % @quoted_fail_name )
  end

  
  def push( data )
    # insert. Easy.
    msg = @connection.escape_string( data.to_json )
    @connection.exec_params( PUSH_QUERY % [@quoted_name, msg] )
  end

  
  # pops a message off the queue; returns 'false' if nothing comes out.
  def pop
    res = @connection.exec( POP_QUERY % [@quoted_name, @quoted_name] )

    # bail on no results
    return false if res.ntuples == 0

    # deconstruct, and parse into JSON
    begin
      {
        id: res[0]['id'],
        ts: res[0]['ts'],
        msg: JSON.parse( res[0]['msg'] )
      }
    rescue => e
      p res[0]
    end
  end
  
  # pushes the message into the failure queue
  def fail( msg )
    msg = data.to_json
    @connection.exec_params( PUSH_QUERY, [fail_name] )
  end

  
  def subscribe( &block )
    while true # yo -- infinite loop dog. danger! high voltage!
      yield msg while msg = pop

      sleep POLL_DELAY
    end
  end

end

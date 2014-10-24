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

class PersistentQueue

  POLL_DELAY = 5 # seconds
  CREATE_QUEUE_QUERY = "CREATE TABLE IF NOT EXISTS ? (id BIGSERIAL PRIMARY KEY, ts TIMESTAMP DEFAULT current_timestamp NOT NULL, msg TEXT NOT NULL)" 
  
  MESSAGES_PER_POLL = 10 # limit on number of messages to pull from the database in one shot
  
  POP_QUERY = "DELETE FROM ? WHERE id=min(id) RETURNING *" # atomic select and delete of the oldest message
  PUSH_QUERY = "INSERT INTO ? (msg) VALUES (?)" # id and ts should automatically populate
  CLEAN_QUERY = "DELETE FROM ? WHERE id IN (?)" # takes a list of ids

  
  def initialize( queue_name, connection_config )
    @name = queue_name
    
    # connect to the database
    @connection = conn = PG::Connection.open( connection_config )

    # create the queue if it doesn't already exist
    @connection.exec_params( CREATE_QUEUE_QUERY, [name] )

    # create the failed message queue if it doesn't already exist
    @fail_name = @name + "_failures"
    @connection.exec_params( CREATE_QUEUE_QUERY, [@fail_name] )
  end

  
  def push( data )
    # insert. Easy.
    msg = data.to_json
    @connection.exec_params( PUSH_QUERY, [name, msg] )
  end

  
  # pops a message off the queue; returns 'false' if nothing comes out.
  def pop
    res = @connection.exec_params( POP_QUERY, [name] )

    # bail on no results
    return false if res.ntuples == 0

    # deconstruct, and parse into JSON
    {
      id: res[0][0],
      ts: res[0][1],
      msg: JSON.parse( res[0][2] )
    }
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

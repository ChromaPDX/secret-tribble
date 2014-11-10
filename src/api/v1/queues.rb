doc "/v1/queues"

get "/v1/queues.json" do
  if require_service_token!
    topic = params[:topic]

    unless topic
      @errors.add("Please specify a topic.")
      return
    end
    
    q = PersistentQueue.new( topic )

    # return a message if we have one.
    q.pop do |msg|
      @out = msg
      return
    end

    # in the case where the queue is empty, return an empty object
    @out = {}
    return
  end
  
  invalid_credentials!
end

post "/v1/queues.json" do
  if require_service_token!
    topic = params[:topic]
    body = params[:body]

    unless topic and body
      @errors.add("Please specify a topic and body.")
      return
    end
    
    q = PersistentQueue.new( topic )    

    begin
      j = JSON.parse body
      @out = q.push( j )
      return
    rescue => e
      @errors.add("body must be a JSON object.")
      return
    end
  end

  invalid_credentials!
end

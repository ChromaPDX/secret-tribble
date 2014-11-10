require_relative 'helper'
require_relative '../persistent_queue.rb'

describe PersistentQueue do

  before( :each ) do
    @topic = "test queue"
  end

  
  it "should push" do
    q = PersistentQueue.new(@topic)

    b1 = { "hello" => "world" }

    m1 = q.push b1

    # ensure the structure of m1 and m2
    expect( m1['message_id'] ).to_not be_nil
    expect( m1['body'] ).to eq( b1 )
    expect( m1['topic'] ).to eq( @topic )
  end

  
  it "should pop" do
    q = PersistentQueue.new( @topic )

    b = { "hello" => "world" }
    m = q.push b

    has_message = false
    q.pop do |m_out|
      expect( m_out[:topic] ).to eq(@topic)
      expect( m_out[:message_id] ).to eq( m['message_id'] )
      expect( m_out[:body] ).to eq( b )
      has_message = true
    end

    expect( has_message ).to be true
  end

  
  it "should log the start and finishing (including status) of a message" do
    
  end

  
  it "should clear all of the messages in a topic" do
    q = PersistentQueue.new( @topic )
    q.clear!

    expect( q.size ).to eq( 0 )
  end
  
end

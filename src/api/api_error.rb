require 'json'

class APIError

  def initialize
    @errors = []
  end

  def errors
    @errors
  end
  
  def add( msg )
    @errors << msg
  end

  def empty?
    @errors.empty?
  end

  def to_json
    { errors: @errors }.to_json
  end

end

require 'sequel'
require 'pg'
require 'json'

module App
  
  @@config_path = false
  @@config = {}
  
  def self.configure!( env_name )

    # load system wide configuration files
    @@config_path = File.join( File.dirname(__FILE__), "..", "config", "#{env_name}.json" )
    @@config = JSON.parse( IO.read(@@config_path) )

    # pull in configuration information from the shell environment.
    default_db_config = {
      adapter: 'postgres',
      host: ENV['CHROMA_DB_HOST'],
      port: ENV['CHROMA_DB_PORT'],
      database: ENV['CHROMA_DB_NAME'],
      user: ENV['CHROMA_DB_USER'],
      password: ENV['CHROMA_DB_PASSWORD'],
    }.delete_if { |k,v| v.nil? or v.empty? }

    # overwrite default_config with the "db" section of @@config
    db_config = default_db_config.merge( @@config["db"] )

    # connect, yo
    @@db = Sequel.connect( db_config )

    # if we got this far ...
    true
  end
  
  def self.config
    @@config
  end
  
  def self.db
    @@db
  end
  
end

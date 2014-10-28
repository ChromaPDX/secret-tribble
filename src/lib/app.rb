require 'sequel'
require 'pg'
require 'json'

module App
  
  @@config_path = false
  @@config = {}
  
  def self.configure!( env_name )

    # load configs specified in the shell environment
    @@shell_config = load_shell_config

    # load configs from environment files
    @@config_path = config_file_path( env_name )
    @@file_config = load_file_config( @@config_path )

    # configs from a file override what's in the environment
    @@config = @@shell_config.merge( @@file_config )
    
    # connect, yo
    @@db = Sequel.connect( @@config["db"] )

    # if we got this far ...
    true
  end

  def self.config_file_path( env_name )
    File.join( File.dirname(__FILE__), "..", "config", "#{env_name}.json" )
  end
  
  def self.load_file_config( path )
    JSON.parse( IO.read(path) )
  end
  
  def self.load_shell_config
    {
      "db" => {
        "adapter" => 'postgres',
        "host" => ENV['CHROMA_DB_HOST'],
        "port" => ENV['CHROMA_DB_PORT'],
        "database" => ENV['CHROMA_DB_NAME'],
        "user" => ENV['CHROMA_DB_USER'],
        "password" => ENV['CHROMA_DB_PASSWORD'],
      }
    }.delete_if { |k,v| v.nil? or v.empty? }
  end
  
  def self.config
    @@config
  end
  
  def self.db
    @@db
  end
  
end

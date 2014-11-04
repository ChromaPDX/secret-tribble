require 'sequel'
require 'pg'
require 'json'
require 'logger'

module App

  @@db_tables = [:pools, :tokens, :accounts, :credentials]
  @@config_path = false
  @@config = {}
  @@db = false
  @@env = nil

  def self.configured?
    !@@env.nil?
  end
  
  def self.configure!( env_name = 'vagrant' )

    puts "Loading configuration '#{env_name}'"
    @@env = env_name

    # load configs specified in the shell environment
    @@shell_config = load_shell_config

    # load configs from file
    @@config_path = config_file_path( env_name )
    @@file_config = load_file_config( @@config_path )

    # configs from environment override what's in the file config
    @@config = @@shell_config.merge( @@file_config )
    
    # connect do the database, yo
    @@db = Sequel.connect( @@config["db"] )

    @@log_path = log_file_path( env_name )
    
    # open a log for the current environment with daily rotation
    @@log = Logger.new( @@log_path, 'daily' )
    @@log.level = Logger.const_get (@@config['log'] || 'DEBUG')
    
    # if we got this far ...
    true
  end

  def self.log_file_path( env_name )
    File.join( File.dirname(__FILE__), "..", "logs", "#{env_name}.log" )
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
        "user" => (ENV['CHROMA_DB_USER'] || ENV['PG_USER']),
        "password" => (ENV['CHROMA_DB_PASSWORD'] || ENV['PG_PASSWORD']),
      }
    }.delete_if { |k,v| v.nil? or v.empty? }
  end
  
  def self.config
    @@config
  end
  
  def self.db
    @@db
  end

  def self.db_tables
    @@db_tables
  end

  def self.log
    @@log
  end

  def self.env
    @@env
  end
  
  # Generates a Unique ID for records in the database.
  # 32 characters long, from a keyspace of 62 characters.
  def self.unique_id
    keyspace = [ *'0'..'9', *'a'..'z', *'A'..'Z']
    32.times.collect { keyspace.sample }.join
  end
  
end

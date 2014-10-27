require 'pg'

module App

  @@db_config = {
    host: ENV['CHROMA_DB_HOST'] || 'localhost',
    port: ENV['CHROMA_DB_PORT'] || '5432',
    dbname: ENV['CHROMA_DB_NAME'] || 'chroma_dev',
    user: ENV['CHROMA_DB_USER'] || 'vagrant',
    password: ENV['CHROMA_DB_PASSWORD'] || 'vagrant',
  }.delete_if { |k,v| v.nil? || v.empty? }

  @@db_connection = false
  
  def self.db_connection
    if @@db_connection and @@db_connection.status == "CONNECTION_OK"
      @@db_connection
    else
      @@db_connection = PG::Connection.open(@@db_config)
    end
  end
  
end

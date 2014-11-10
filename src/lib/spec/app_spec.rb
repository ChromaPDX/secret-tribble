require_relative 'helper'
require_relative "../app"

describe "App" do

  it "should load config information from the shell environment" do
    ENV['CHROMA_DB_HOST'] = "host"
    ENV['CHROMA_DB_PORT'] = "port"
    ENV['CHROMA_DB_NAME'] = "database"
    ENV['CHROMA_DB_USER'] = "user"
    ENV['CHROMA_DB_PASSWORD'] = "password"
    
    shell_cfg = App.load_shell_config

    expect( shell_cfg['db'] ).to eq({
                                      "adapter" => "postgres",
                                      "host" => "host",
                                      "port" => "port",
                                      "database" => "database",
                                      "user" => "user",
                                      "password" => "password"
                                    })
  end

  it "should load config information from a named environment" do
    file_path = App.config_file_path( "vagrant" )
    file_cfg = App.load_file_config( file_path )

    expect( file_cfg['db'] ).to eq({
                                     "adapter" => "postgres",
                                     "host" => "localhost",
                                     "port" => "5432",
                                     "database" => "chroma_dev",
                                     "user" => "vagrant",
                                     "password" => "vagrant"
                                   })
  end

  it "should generate unique_ids for use as keys in the database" do
    # this is a weak test; maybe make a longer one someday?
    sample = 1000
    keys = sample.times.collect { App.unique_id }
    expect( keys.uniq.count ).to eq( sample )
  end

  it "should provide a logging interface" do
    # currently logs to the filesystem
    App.log.info("yolo")
    expect( File.exist?( App.log_file_path(App.env) ) ).to be true
  end

end

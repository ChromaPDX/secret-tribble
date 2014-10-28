require_relative "../lib/app"

describe "App" do

  it "should load config information from the shell environment" do
    ENV['CHROMA_DB_HOST'] = "host"
    ENV['CHROMA_DB_PORT'] = "port"
    ENV['CHROMA_DB_NAME'] = "database"
    ENV['CHROMA_DB_USER'] = "user"
    ENV['CHROMA_DB_PASSWORD'] = "password"
    
    shell_cfg = App.load_shell_config

    expect( shell_cfg ).to eq({
                                "db" => {
                                  "adapter" => "postgres",
                                  "host" => "host",
                                  "port" => "port",
                                  "database" => "database",
                                  "user" => "user",
                                  "password" => "password"
                                }
                              })
  end

  it "should load config information from a named environment" do
    file_path = App.config_file_path( "vagrant" )
    file_cfg = App.load_file_config( file_path )

    expect( file_cfg ).to eq({
                                "db" => {
                                  "adapter" => "postgres",
                                  "host" => "localhost",
                                  "port" => "5432",
                                  "database" => "chroma_dev",
                                  "user" => "vagrant",
                                  "password" => "vagrant"
                                }
                              })
  end
  
end

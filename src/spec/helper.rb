require_relative '../lib/app'
require 'fileutils'

RSpec.configure do |cfg|
  cfg.before(:suite) do
    chroma_env = (ENV['CHROMA_ENV'] || 'test')
    
    # clean out the log files for the environment
    FileUtils.rm_f App.log_file_path(chroma_env)

    # set up the environment
    App.configure! chroma_env
  end

  cfg.after(:suite) do
    # wipe everything out of the test database
    [:distributions].each do |table|
      App.db[table].delete
    end
  end
end

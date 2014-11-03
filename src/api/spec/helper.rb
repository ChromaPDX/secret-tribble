
# some intialization hacks needed before we include api.rb
require 'rspec'
require 'rack/test'
require 'fileutils'
require_relative '../../lib/app'
ENV['CHROMA_ENV'] ||= 'test'
FileUtils.rm_f App.log_file_path(ENV['CHROMA_ENV'])
App.configure!( ENV['CHROMA_ENV'] )

require_relative '../api.rb'

RSpec.configure do |cfg|
  cfg.before(:suite) do
    # wipe everything out of the test database
    [:distributions].each do |table|
      App.db[table].delete
    end
  end
end

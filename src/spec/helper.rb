require_relative '../lib/app'

RSpec.configure do |cfg|
  cfg.before(:suite) do
    App.configure! (ENV['CHROMA_ENV'] || "test")
  end

  cfg.after(:suite) do
    # wipe everything out of the test database
    [:distributions].each do |table|
      App.db[table].delete
    end
  end
end

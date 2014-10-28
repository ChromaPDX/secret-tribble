require_relative '../lib/app'

RSpec.configure do |cfg|
  cfg.before(:suite) do
    App.configure! "test"
  end
end

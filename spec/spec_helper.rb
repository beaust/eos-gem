require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

# Require all lib/ files.
Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each { |f| require f }

RSpec.configure do |c|
  c.mock_framework = :rspec
  # Ensure specs run in a random order to surface order depenencies
  c.order = 'random'
end

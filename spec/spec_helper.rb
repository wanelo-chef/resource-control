require 'bundler/setup'
require 'chefspec'
require 'aruba/rspec'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f unless /_spec\.rb$/.match(f) }

RSpec.configure do |c|
  c.include ArubaDoubles
  c.include ChefHelpers
  c.extend ProjectHelpers

  c.before :each do
    setup_chef
    Aruba::RSpec.setup
  end

  c.after :each do
    Aruba::RSpec.teardown
    reset_chef
  end
end

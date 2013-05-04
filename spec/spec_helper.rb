require 'bundler/setup'
require 'chefspec'
require 'aruba-doubles'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f unless /_spec\.rb$/.match(f) }

RSpec.configure do |c|
  c.include ArubaDoubles
  c.include ChefHelpers

  c.before :each do
    setup_chef
    ArubaDoubles::Double.setup
  end

  c.after :each do
    ArubaDoubles::Double.teardown
    history.clear
    reset_chef
  end
end

require 'bundler/setup'
require 'chefspec'
require 'aruba-doubles'
require 'pry'

RSpec.configure do |c|
  include ArubaDoubles

  c.before :each do
    ArubaDoubles::Double.setup
  end

  c.after :each do
    ArubaDoubles::Double.teardown
    history.clear
  end
end

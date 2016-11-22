require 'bundler/setup'

Bundler.require(:default, :development)

require (Pathname.new(__FILE__).dirname + '../lib/armadura').expand_path

module Armadura
  module Test; end
end

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.include ArmaduraTestHelpers
  config.include Armadura::Test::Matchers
end

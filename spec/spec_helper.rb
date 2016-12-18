require 'bundler/setup'

Bundler.require(:default, :development)

require (Pathname.new(__FILE__).dirname + '../lib/hashira/rails').expand_path

module Hashira
  module Test; end
end

Dir.glob(
  File.expand_path("../support/{.,helpers,matchers}/*.rb", __FILE__)
).each { |file| require file }

RSpec.configure do |config|
  config.include HashiraTestHelpers
  config.include Hashira::Test::Matchers
end

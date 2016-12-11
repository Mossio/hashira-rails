require 'bundler/setup'

Bundler.require(:default, :development)

require (Pathname.new(__FILE__).dirname + '../lib/hashira/rails').expand_path

module Hashira
  module Test; end
end

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.include HashiraTestHelpers
  config.include Hashira::Test::Matchers
end

module Armadura
  RAILS_VERSION = "~> 5.0.0.1".freeze
  RUBY_VERSION = IO.
    read("#{File.dirname(__FILE__)}/../../.ruby-version").
    strip.
    freeze
  VERSION = "1.42.0".freeze
end

module Hashira
  module Rails
    RAILS_VERSION = "~> 5.0.0.1".freeze
    RUBY_VERSION = IO.
      read("#{File.dirname(__FILE__)}/../../../.ruby-version").
      strip.
      freeze
    VERSION = "0.1.2".freeze
  end
end

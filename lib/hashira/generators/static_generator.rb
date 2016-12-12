require "rails/generators"
require "hashira/rails/sub_generator"

module Hashira
  class StaticGenerator < Hashira::Rails::SubGenerator
    def add_high_voltage
      gem "high_voltage"
    end

    def run_bundle
      if !parent_generator
        bundle_command("install")
      end
    end

    private

    attr_reader :parent_generator
  end
end

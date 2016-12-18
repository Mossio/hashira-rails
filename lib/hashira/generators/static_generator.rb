require "hashira/rails/sub_generator"

module Hashira
  class StaticGenerator < Hashira::Rails::SubGenerator
    def add_high_voltage
      gem "high_voltage"
    end
  end
end

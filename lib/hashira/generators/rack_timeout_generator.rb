require "hashira/rails/generator_base"

module Hashira
  class RackTimeoutGenerator < Hashira::Rails::GeneratorBase
    def add_rack_timeout_to_gemfile
      updating_gemfile do |gemfile|
        gemfile.add_gem "rack-timeout", group: :production
        gemfile.organize
      end

      run_bundle_install
    end

    def configure_production_environment_with_timeout
      append_to_file "config/environments/production.rb",
        %(\n\nRack::Timeout.timeout = ENV.fetch("RACK_TIMEOUT", 10).to_i\n)
    end
  end
end

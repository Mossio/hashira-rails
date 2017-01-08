require "hashira/rails/generator_base"

module Hashira
  class RackCanonicalHostGenerator < Hashira::Rails::GeneratorBase
    def add_rack_canonical_host_to_gemfile
      updating_gemfile do |gemfile|
        gemfile.add_gem "rack-canonical-host", group: :production
        gemfile.organize
      end

      run_bundle_install
    end

    def add_middleware_to_production_environment
      insert_into_file "config/environments/production.rb",
        %(\n  config.middleware.use Rack::CanonicalHost, ENV.fetch("APPLICATION_HOST")),
        before: /\nend\Z/
    end
  end
end

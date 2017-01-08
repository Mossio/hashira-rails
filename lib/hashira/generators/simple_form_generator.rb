require "hashira/rails/generator_base"

module Hashira
  class SimpleFormGenerator < Hashira::Rails::GeneratorBase
    def add_simple_form_to_gemfile
      updating_gemfile do |gemfile|
        gemfile.add_gem "simple_form"
        gemfile.organize
      end

      run_bundle_install
    end

    def run_simple_form_install
      generate "simple_form:install"
    end
  end
end

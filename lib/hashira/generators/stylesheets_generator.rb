require "hashira/rails/generator_base"
require "hashira/rails/actions/rename_file"

module Hashira
  class StylesheetsGenerator < Hashira::Rails::GeneratorBase
    STYLESHEETS_DIR = "app/assets/stylesheets"

    def add_gems
      updating_gemfile do |gemfile|
        gemfile.add_gem "normalize-rails"
        gemfile.add_gem "bourbon", version: "5.0.0.beta.7"
        gemfile.add_gem "neat"
        gemfile.add_gem "bitters", group: :development
        gemfile.organize
      end

      run_bundle_install
    end

    def install_base_stylesheets
      run "bitters install --path #{STYLESHEETS_DIR}"
      rename_file(
        "#{STYLESHEETS_DIR}/base/_base.scss",
        "#{STYLESHEETS_DIR}/base/_index.scss",
      )
    end

    def replace_application_stylesheet
      remove_file "#{STYLESHEETS_DIR}/application.css"
      copy_file "application.scss", "#{STYLESHEETS_DIR}/application.scss"
    end

    def add_components_index
      copy_file(
        "components_index.scss",
        "#{STYLESHEETS_DIR}/components/_index.scss",
      )
    end

    def add_modules_index
      copy_file(
        "modules_index.scss",
        "#{STYLESHEETS_DIR}/modules/_index.scss",
      )
    end
  end
end

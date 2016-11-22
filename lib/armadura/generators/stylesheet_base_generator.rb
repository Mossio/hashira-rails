require "rails/generators"

module Armadura
  class StylesheetBaseGenerator < Rails::Generators::Base
    source_root File.expand_path(
      File.join("..", "..", "..", "templates"),
      File.dirname(__FILE__))

    def add_stylesheet_gems
      gem "bourbon", "5.0.0.beta.7"
      gem "neat", "~> 1.8.0"
      gem "refills", group: [:development, :test]
      Bundler.with_clean_env { run "bundle install" }
    end

    def add_css_config
      copy_file(
        "application.scss",
        "app/assets/stylesheets/application.scss",
        force: true,
      )
    end

    def remove_prior_config
      remove_file "app/assets/stylesheets/application.css"
    end

    def install_refills
      generate "refills:import", "flashes"
      remove_dir "app/views/refills"
    end

    def install_bitters
      run "bitters install --path app/assets/stylesheets"
    end
  end
end

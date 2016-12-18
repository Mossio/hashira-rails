require "rails/generators"
require "hashira/rails/sub_generator"

module Hashira
  class StylesheetBaseGenerator < Hashira::Rails::SubGenerator
    def add_stylesheet_gems
      gem "bourbon", "5.0.0.beta.7"
      gem "neat", "~> 1.8.0"
      gem "refills", group: [:development, :test]
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
      after_bundle do
        generate "refills:import", "flashes"
        remove_dir "app/views/refills"
      end
    end

    def install_bitters
      after_bundle do
        run "bitters install --path app/assets/stylesheets"
      end
    end
  end
end

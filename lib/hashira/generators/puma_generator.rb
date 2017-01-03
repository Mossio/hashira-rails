require "hashira/rails/generator_base"

module Hashira
  class PumaGenerator < Hashira::Rails::GeneratorBase
    def replace_puma_config_file
      copy_file "puma.rb", "config/puma.rb", force: true
    end

    def add_web_concurrency_to_env_example
      append_to_file ".env.example", "WEB_CONCURRENCY=1\n"
    end

    def ensure_puma_is_present_in_procfile
      if path_to_file("Procfile").exist?
        gsub_file "Procfile",
          /^web:.+$/,
          "web: bundle exec puma -C config/puma.rb"
      else
        create_file "Procfile", "web: bundle exec puma -C config/puma.rb\n"
      end
    end
  end
end

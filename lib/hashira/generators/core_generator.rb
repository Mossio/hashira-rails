require "hashira/rails/generator_base"
require "hashira/rails/gemfile"

module Hashira
  class CoreGenerator < Hashira::Rails::GeneratorBase
    def copy_dotfiles
      directory "dotfiles", "."
    end

    def establish_ruby_version
      create_file ".ruby-version", "#{Hashira::Rails::RUBY_VERSION}\n"
    end

    def update_gemfile
      Hashira::Rails::Gemfile.open(destination_root) do |gemfile|
        gemfile.set_ruby Hashira::Rails::RUBY_VERSION
        gemfile.replace_gem "rails", version: Hashira::Rails::RAILS_VERSION
        gemfile.remove_gem "jbuilder"
        gemfile.organize
      end
    end

    def replace_setup_script
      template "bin_setup.erb", "bin/setup", force: true
      run "chmod a+x bin/setup"
    end

    def replace_translations_file
      create_file "config/locales/en.yml", "en:\n", force: true
    end

    def add_useful_date_and_time_formats_to_translations_file
      add_translations(
        date: {
          formats: {
            full: "%B %-d, %Y",
            shorter: "%b %-d, %Y",
            full_without_year: "%B %-d",
            shorter_without_year: "%b %-d",
            standard: "%-m/%-d/%Y",
            standard_without_year: "%-m/%-d",
          }
        },
        time: {
          formats: {
            full: "%B %-d, %Y at %-I:%M %p",
            shorter: "%b %-d, %Y at %-I:%M %p",
            standard: "%-m/%-d/%Y, %-I:%M%P",
          }
        },
      )
    end

    def disable_wrap_parameters
      remove_file "config/initializers/wrap_parameters.rb"
    end

    def customize_error_pages
      meta_tags = <<-EOS
  <meta charset="utf-8" />
  <meta name="ROBOTS" content="NOODP" />
      EOS

      [404, 422, 500].each do |page|
        inject_into_file "public/#{page}.html", meta_tags, after: "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_comments_from_config_files
      config_files = [
        "config/application.rb",
        "config/environment.rb",
        "config/environments/development.rb",
        "config/environments/production.rb",
        "config/environments/test.rb",
      ]

      config_files.each do |file|
        remove_commented_lines_from(file)
        clean_up_spacing_in(file)
      end
    end

    def configure_action_mailer_in_dev_and_prod_not_to_swallow_delivery_errors
      replace_in_file(
        "config/environments/development.rb",
        "config.action_mailer.raise_delivery_errors = false",
        "config.action_mailer.raise_delivery_errors = true",
      )
      inject_into_file(
        "config/environments/production.rb",
        "  config.action_mailer.raise_delivery_errors = true\n",
        after: "config.action_mailer.perform_caching = false\n",
      )
    end

    def configure_action_mailer_in_dev_to_log_emails_in_files
      inject_into_file(
        "config/environments/development.rb",
        "\n  config.action_mailer.delivery_method = :file",
        after: "config.action_mailer.raise_delivery_errors = true",
      )
    end

    def configure_smtp_settings_in_production
      copy_file "smtp.rb", "config/smtp.rb"

      prepend_file "config/environments/production.rb",
        %(require Rails.root.join("config/smtp.rb")\n\n)

      config = <<-RUBY
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
      RUBY
      inject_into_file "config/environments/production.rb",
        config,
        after: "config.action_mailer.raise_delivery_errors = true\n"
    end

    def add_seed_task_and_supporting_files
      copy_file "dev.rake", "lib/tasks/dev.rake"
      copy_file "development_soil.rb", "lib/development_soil.rb"
    end

    def configure_active_job_to_use_inline_adapter_in_tests
      inject_into_file "config/environments/test.rb",
        "config.active_job.queue_adapter = :inline\n",
        after: "config.active_support.deprecation = :stderr\n"
    end

    def initialize_git_repo
      run "git init"
    end

    def install_gems
      run_bundle
    end
  end
end

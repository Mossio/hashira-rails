require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "hashira/generators/static_generator"
require "hashira/generators/stylesheet_base_generator"

module Hashira
  class AppGenerator < ::Rails::Generators::AppGenerator
    def self.banner
      "hashira-rails #{arguments.map(&:usage).join(' ')} [options]"
    end

    hide!

    class_option :database, type: :string, aliases: "-d", default: "postgresql",
      desc: "Configure for selected database (options: #{DATABASES.join("/")})"

    class_option :heroku, type: :boolean, aliases: "-H", default: false,
      desc: "Create staging and production Heroku apps"

    class_option :heroku_flags, type: :string, default: "",
      desc: "Set extra Heroku flags"

    class_option :github, type: :string, default: nil,
      desc: "Create Github repository and add remote origin pointed to repo"

    class_option :version, type: :boolean, aliases: "-v", group: :hashira,
      desc: "Show hashira-rails version number and quit"

    class_option :help, type: :boolean, aliases: '-h', group: :hashira,
      desc: "Show this help message and quit"

    class_option :path, type: :string, default: nil,
      desc: "Path to the gem"

    class_option :profile, type: :boolean, default: false,
      desc: "Profile generator steps and print a report at the end"

    DEFAULT_GENERATORS = [
      {
        name: :static,
        class: Hashira::StaticGenerator,
      },
      {
        name: :stylesheet_base,
        class: Hashira::StylesheetBaseGenerator,
      },
    ]

    def initialize(*)
      super

      @profile =
        if options[:profile]
          Hashira::Rails::Profile.instance
        else
          Hashira::Rails::InertProfile.new
        end
    end

    def finish_template
      build_with_profiling :set_ruby_to_version_being_used

      setup_spring
      configure_simple_form
      setup_development_environment
      setup_test_environment
      setup_production_environment
      setup_secret_token
      create_hashira_views
      configure_app
      copy_miscellaneous_files
      customize_error_pages
      remove_config_comment_lines
      remove_routes_comment_lines
      setup_dotfiles
      setup_git
      setup_database
      create_local_heroku_setup
      create_heroku_apps
      create_github_repo
      setup_segment
      setup_bundler_audit
      generate_default

      super
    end

    def outro
      say 'The Rails application is now created!'
    end

    def display_profiling_report
      profile.report
    end

    protected

    def get_builder_class
      Hashira::Rails::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end

    private

    attr_reader :profile, :default_generators

    def default_generators
      @_default_generators ||=
        DEFAULT_GENERATORS.map do |generator|
          instance = generator[:class].new(
            ARGV,
            {},
            destination_root: destination_root,
          )
          instance.parent_generator = self
          { name: generator[:name], instance: instance }
        end
    end

    def setup_database
      say 'Setting up database'

      if options[:database] == 'postgresql'
        build_with_profiling :use_postgres_config_template
      end

      after_bundle do
        build_with_profiling :create_database
      end
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build_with_profiling :raise_on_missing_assets_in_test
      build_with_profiling :raise_on_delivery_errors
      build_with_profiling :remove_turbolinks
      build_with_profiling :set_test_delivery_method
      build_with_profiling :add_bullet_gem_configuration
      build_with_profiling :raise_on_unpermitted_parameters
      build_with_profiling :provide_setup_script
      build_with_profiling :provide_dev_prime_task
      build_with_profiling :configure_generators
      build_with_profiling :configure_i18n_for_missing_translations
      build_with_profiling :configure_quiet_assets
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build_with_profiling :set_up_factory_girl_for_rspec
      build_with_profiling :generate_factories_file
      build_with_profiling :set_up_hound

      after_bundle do
        build_with_profiling :generate_rspec
      end

      build_with_profiling :enable_database_cleaner
      build_with_profiling :provide_shoulda_matchers_config
      build_with_profiling :configure_spec_support_features
      build_with_profiling :configure_ci
      build_with_profiling :configure_i18n_for_test_environment
      build_with_profiling :configure_action_mailer_in_specs
      build_with_profiling :configure_capybara_webkit
      build_with_profiling :remove_test_directory
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build_with_profiling :configure_smtp
      build_with_profiling :configure_rack_timeout
      build_with_profiling :enable_rack_canonical_host
      build_with_profiling :enable_rack_deflater
      build_with_profiling :setup_asset_host
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
      build_with_profiling :setup_secret_token
    end

    def create_hashira_views
      say 'Creating hashira views'
      build_with_profiling :create_partials_directory
      build_with_profiling :create_shared_flashes
      build_with_profiling :create_shared_javascripts
      build_with_profiling :create_shared_css_overrides
      build_with_profiling :create_application_layout
    end

    def configure_app
      say 'Configuring app'
      build_with_profiling :configure_action_mailer
      build_with_profiling :configure_active_job
      build_with_profiling :configure_sidekiq
      build_with_profiling :configure_time_formats
      build_with_profiling :setup_default_rake_task
      build_with_profiling :replace_default_puma_configuration
      build_with_profiling :set_up_forego
      build_with_profiling :setup_rack_mini_profiler

      after_bundle do
        build_with_profiling :add_bower
      end

      after_bundle do
        build_with_profiling :add_teaspoon
      end
    end

    def setup_git
      if !options[:skip_git]
        say "Initializing git"
        setup_default_directories
        init_git
      end
    end

    def create_local_heroku_setup
      say "Creating local Heroku setup"
      build_with_profiling :create_review_apps_setup_script
      build_with_profiling :create_deploy_script
      build_with_profiling :create_heroku_application_manifest_file
    end

    def create_heroku_apps
      if options[:heroku]
        say "Creating Heroku apps"
        build_with_profiling :create_heroku_apps, options[:heroku_flags]
        build_with_profiling :set_heroku_remotes
        build_with_profiling :set_heroku_rails_secrets
        build_with_profiling :set_heroku_application_host
        build_with_profiling :create_heroku_pipeline
        build_with_profiling :configure_automatic_deployment
      end
    end

    def create_github_repo
      if !options[:skip_git] && options[:github]
        say 'Creating Github repo'
        build_with_profiling :create_github_repo, options[:github]
      end
    end

    def setup_segment
      say 'Setting up Segment'
      build_with_profiling :setup_segment
    end

    def setup_dotfiles
      build_with_profiling :copy_dotfiles
    end

    def setup_default_directories
      build_with_profiling :setup_default_directories
    end

    def setup_bundler_audit
      say "Setting up bundler-audit"
      build_with_profiling :setup_bundler_audit
    end

    def init_git
      build_with_profiling :init_git
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build_with_profiling :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build_with_profiling :customize_error_pages
    end

    def remove_config_comment_lines
      build_with_profiling :remove_config_comment_lines
    end

    def remove_routes_comment_lines
      build_with_profiling :remove_routes_comment_lines
    end

    def generate_default
      default_generators.each do |generator|
        directly_generate(generator)
      end
    end

    def setup_spring
      after_bundle do
        build_with_profiling :setup_spring
      end
    end

    def configure_simple_form
      after_bundle do
        build_with_profiling :configure_simple_form
      end
    end

    def build_with_profiling(name, *args)
      profile.measuring_build(name) { build(name, *args) }
    end

    # Override to use Spring
    def generate(what, *args)
      log :generate, what
      argument = args.flat_map(&:to_s).join(" ")
      run_spring_command("rails generate #{what} #{argument}", log: false)
    end

    def run_spring_command(command, log: true)
      run_command_in_app("bin/spring #{command}", log: log)
    end

    def run_command_in_app(command, log: true)
      if log
        log(:run, command)
      end

      in_root do
        run_ruby_script command, verbose: false
      end
    end

    def directly_generate(generator)
      log :generate, generator[:name]
      generator[:instance].invoke_all
    end
  end
end

require "rails/generators"
require "rails/generators/base"
require "hashira/rails/actions"

module Hashira
  module Rails
    # This class, unfortunately, has to end in "Base" so that it doesn't get
    # considered as a possible generator
    class GeneratorBase < ::Rails::Generators::Base
      TEMPLATES_DIRECTORY = File.expand_path(
        "../../../../templates",
        __FILE__,
      )

      include Hashira::Rails::Actions

      def self.inherited(subclass)
        super

        subclass.source_root(TEMPLATES_DIRECTORY)

        # Thor runs commands in the order that they were defined,
        # so define this method dynamically so as to place it after any
        # methods that the subclass may already have
        subclass.class_eval do
          def run_bundle
            if !parent_generator
              bundle_command("install")
            end
          end

          def run_after_bundle_callbacks
            @after_bundle_callbacks.each(&:call)
          end
        end
      end

      attr_writer :parent_generator

      protected

      attr_reader :parent_generator

      def after_bundle(&block)
        if parent_generator
          parent_generator.after_bundle(&block)
        else
          super
        end
      end

      # Copied from AppBase
      def bundle_command(command)
        say_status :run, "bundle #{command}"

        # We are going to shell out rather than invoking
        # Bundler::CLI.new(command) because `rails new` loads the Thor gem and
        # on the other hand bundler uses its own vendored Thor, which could be a
        # different version. Running both things in the same process is a recipe
        # for a night with paracetamol.
        #
        # We unset temporary bundler variables to load proper bundler and
        # Gemfile.
        #
        # Thanks to James Tucker for the Gem tricks involved in this call.
        _bundle_command = Gem.bin_path("bundler", "bundle")

        require "bundler"

        Bundler.with_clean_env do
          full_command = %Q["#{Gem.ruby}" "#{_bundle_command}" #{command}]
          if options[:quiet]
            system(full_command, out: File::NULL)
          else
            system(full_command)
          end
        end
      end

      def app_name
        hashira_config_file = path_to_file(".hashira.json")

        if hashira_config_file.exist?
          JSON.parse(hashira_config_file.read)["app_name"]
        else
          File.basename(destination_root)
        end
      end

      def ruby_version
        Hashira::Rails::RUBY_VERSION
      end
    end
  end
end

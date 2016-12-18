require "hashira/rails/clean_up_spacing_in"

module Hashira
  module Rails
    module Actions
      class IrreversibleAction < StandardError; end

      # TODO: This should be replaced with gsub_file
      def replace_in_file(relative_path, find, replace)
        path = File.join(destination_root, relative_path)
        contents = IO.read(path)
        unless contents.gsub!(find, replace)
          raise "#{find.inspect} not found in #{relative_path}"
        end
        File.open(path, "w") { |file| file.write(contents) }
      end

      def action_mailer_host(rails_env, host)
        config = "config.action_mailer.default_url_options = { host: #{host} }"
        configure_environment(rails_env, config)
      end

      def configure_application_file(config)
        inject_into_file(
          "config/application.rb",
          "\n\n    #{config}",
          before: "\n  end"
        )
      end

      def configure_environment(rails_env, config)
        inject_into_file(
          "config/environments/#{rails_env}.rb",
          "\n\n  #{config}",
          before: "\nend"
        )
      end

      def add_translations(new_translations)
        if behavior == :invoke
          normalized_new_translations = {
            "en" => new_translations.deep_stringify_keys,
          }
          translations_file = path_to_file("config/locales/en.yml")
          existing_translations = YAML.load(translations_file.read)
          merged_translations =
            existing_translations.deep_merge(normalized_new_translations)
          YAML.dump(merged_translations, translations_file.open("w"))
        else
          raise IrreversibleAction.new(
            "add_translations is not reversible"
          )
        end
      end

      def remove_commented_lines_from(relative_path)
        gsub_file relative_path, /^[ ]*#.*\n/, ""
      end

      def clean_up_spacing_in(relative_path)
        Hashira::Rails::CleanUpSpacingIn.(relative_path)
      end

      private

      def path_to_file(relative_path)
        Pathname.new(File.join(destination_root, relative_path))
      end

      class Group < Array
      end
    end
  end
end

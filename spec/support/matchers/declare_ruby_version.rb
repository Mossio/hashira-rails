module Hashira
  module Test
    module Matchers
      def declare_ruby_version(version)
        DeclareRubyVersionMatcher.new(version)
      end

      class DeclareRubyVersionMatcher
        def initialize(expected_version)
          @expected_version = expected_version
        end

        def matches?(gemfile_file)
          @gemfile_file = gemfile_file

          actual_ruby_version &&
            actual_ruby_version.versions.include?(expected_version)
        end

        def failure_message
          message = "Expected Gemfile to declare Ruby version " +
            "#{expected_version.inspect}"

          if actual_ruby_version
            message << ", but the version was #{actual_ruby_version.versions}."
          else
            message << ", but it did not declare a version."
          end

          message
        end

        private

        attr_reader :expected_version, :gemfile_file

        def gemfile
          @_gemfile ||= Bundler::Dsl.new.tap do |dsl|
            dsl.eval_gemfile(gemfile_file)
          end
        end

        def actual_ruby_version
          gemfile.instance_variable_get("@ruby_version")
        end
      end
    end
  end
end

module Hashira
  module Test
    module Matchers
      def self.stringify_keys(hash)
        hash.reduce({}) do |new_hash, (key, value)|
          new_hash.merge(key.to_s => value)
        end
      end

      def list_gem(gem_name, version: nil, **options)
        ListGemMatcher.new(gem_name, version, options)
      end

      class ListGemMatcher
        def initialize(gem_name, version, options)
          @expected_dependency = Bundler::Dependency.new(
            gem_name,
            version,
            Matchers.stringify_keys(options),
          )
        end

        def matches?(gemfile_file)
          @gemfile_file = gemfile_file

          gemfile.dependencies.any? do |actual_dependency|
            dependencies_match?(actual_dependency, expected_dependency)
          end
        end

        def failure_message
          "Expected Gemfile to #{expectation}, but it did not."
        end

        def failure_message_when_negated
          "Expected Gemfile not to #{expectation}, but it did."
        end

        private

        attr_reader :expected_dependency, :gemfile_file

        def gemfile
          @_gemfile ||= Bundler::Dsl.new.tap do |dsl|
            dsl.eval_gemfile(gemfile_file)
          end
        end

        def dependencies_match?(dependency1, dependency2)
          dependency1.name == dependency2.name &&
            (
              dependency1.requirement.none? ||
              dependency2.requirement.none? ||
              dependency1.requirement == dependency2.requirement
            ) &&
            dependency1.autorequire == dependency2.autorequire &&
            dependency1.groups == dependency2.groups
        end

        def expectation
          groups = expected_dependency.groups - [:default]
          message = "contain #{expected_dependency.name.inspect}"

          if !expected_dependency.requirement.none?
            message << " (#{expected_dependency.version})"
          end

          if groups.any?
            message << " in groups: #{groups.inspect}"
          end

          message
        end
      end
    end
  end
end

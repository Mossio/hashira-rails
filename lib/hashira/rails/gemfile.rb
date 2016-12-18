module Hashira
  module Rails
    class Gemfile
      def self.open(base_path)
        full_path = File.join(base_path, "Gemfile")
        gemfile = new(full_path)
        yield gemfile
        gemfile.write
      end

      def initialize(full_path)
        @io = Pathname.new(full_path).open("r+")
        @builder = Bundler::Dsl.new.tap { |dsl| dsl.eval_gemfile("Gemfile") }
      end

      def set_ruby(version)
        builder.ruby(version)
      end

      def add_gem(gem_name, version: nil, **options)
        builder.gem(gem_name, version, **options)
      end

      def remove_gem(gem_name)
        builder.dependencies.reject! do |dependency|
          dependency.name == gem_name
        end
      end

      def replace_gem(gem_name, version: nil, **options)
        remove_gem(gem_name)
        add_gem(gem_name, version: version, **options)
      end

      def organize
        @grouped_dependencies_to_write = grouped_and_sorted_dependencies
      end

      def write
        io.truncate(0)
        io.write(content_to_write)
        io.close
      end

      private

      attr_reader :io, :builder

      def set_ruby_version
        ruby_version = builder.instance_variable_get("@ruby_version")

        if ruby_version
          ruby_version.versions.first
        end
      end

      def set_rubygems_source
        source =
          builder.instance_variable_get("@sources").rubygems_sources.first

        if source
          source.remotes.first.to_s
        end
      end

      def grouped_dependencies_to_write
        @grouped_dependencies_to_write ||= grouped_dependencies
      end

      def grouped_dependencies
        builder.dependencies.group_by(&:groups)
      end

      def grouped_and_sorted_dependencies
        grouped_dependencies.
          sort_by { |groups, _| groups.size }.
          map { |groups, dependencies| [groups, dependencies.sort_by(&:name)] }
      end

      def content_to_write
        groups = []

        if set_rubygems_source
          groups << "source #{set_rubygems_source.inspect}"
        end

        if set_ruby_version
          groups << "ruby #{set_ruby_version.inspect}"
        end

        groups += lines_for_groups

        groups.join("\n\n")
      end

      def lines_for_groups
        grouped_dependencies_to_write.map do |groups, dependencies|
          line_for_group(groups, dependencies)
        end
      end

      def line_for_group(groups, dependencies)
        lines = []
        lines << "group #{groups.map(&:inspect).join(", ")} do"

        dependencies.each do |dependency|
          lines << "  " + line_for_dependency(dependency)
        end

        lines << "end"

        lines.join("\n")
      end

      def line_for_dependency(dependency)
        source = dependency.instance_variable_get("@source")
        parts = [
          "gem #{dependency.name.inspect}",
          inspect_requirement(dependency.requirement),
        ]

        if dependency.autorequire
          parts << "require: #{dependency.autorequire.inspect}"
        end

        if source
          parts << "path: #{source.path.to_s.inspect}"
        end

        parts.compact.join(", ")
      end

      def inspect_requirement(requirement)
        versions = requirement.as_list

        if !requirement.none? && !versions.empty?
          if versions.size == 1
            if versions[0].start_with?("=")
              versions[0][1..-1].inspect
            else
              versions[0].inspect
            end
          else
            versions.inspect
          end
        end
      end
    end
  end
end

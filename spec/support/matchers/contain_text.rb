module Armadura::Test
  module Matchers
    def contain_text(content, match: :all)
      ContainText.new(content, match)
    end

    def contain_line(content)
      ContainText.new(content, :stripped_line)
    end

    class ContainText
      include Armadura::Test::TerminalOutputHelpers

      def initialize(expected_content, matching_strategy)
        @expected_content = expected_content
        @matching_strategy = matching_strategy
      end

      def matches?(pathname)
        @pathname = pathname

        if matching_strategy == :stripped_line
          actual_stripped_lines.any? { |line| line == expected_content }
        elsif matching_strategy == :line
          actual_lines.any? { |line| expected_content === line }
        elsif matching_strategy == :exact
          actual_content == expected_content
        elsif expected_content.is_a?(String)
          actual_content.include?(expected_content)
        else
          actual_content =~ expected_content
        end
      end

      def failure_message
        message = "Expected #{simplified_file_path.inspect}\nto "
        message << expectation
        message << "However, it did not. Actual content was:\n\n"
        message << divider("START") + actual_content + divider("END")
      end

      def failure_message_when_negated
        message = "Expected #{simplified_file_path.inspect}\nnot to "
        message << expectation
        message << "However, it did."
      end

      private

      attr_reader :expected_content, :pathname, :matching_strategy

      def expectation
        if matching_strategy == :stripped_line
          message << "have a line which, after being stripped, is"
          message << "#{expected_content.inspect}.\n\n"
        elsif matching_strategy == :line
          if expected_content.is_a?(String)
            message << "have a line which is #{expected_content.inspect}.\n\n"
          else
            message << "have a line containing #{expected_content.inspect}.\n\n"
          end
        else
          if matching_strategy == :exact
            message << "match content exactly:\n\n"
          else
            message << "contain content:\n\n"
          end
          message << divider("START")
          message << expected_content_with_ending_line
          message << divider("END")
          message << "\n"
        end
      end

      def simplified_file_path
        pathname.sub(Armadura::Test.project_directory.to_s, "~").to_s
      end

      def actual_stripped_lines
        actual_lines.map(&:strip)
      end

      def actual_lines
        actual_content.split("\n")
      end

      def actual_content
        @_actual_content ||= pathname.read
      end

      def expected_content_with_ending_line
        if expected_content.end_with?("\n")
          expected_content
        else
          expected_content + "\n"
        end
      end
    end
  end
end

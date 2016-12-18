module Hashira::Test
  module Matchers
    def contain_text(content, match: :all)
      ContainText.new(content, match)
    end

    def contain_line(content)
      if content.is_a?(Regexp)
        ContainText.new(content, :line)
      else
        ContainText.new(content, :stripped_line)
      end
    end

    class ContainText
      include Hashira::Test::TerminalOutputHelpers

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
        message << "However, it did not. Full content of file is:\n\n"
        message << divider("START")
        message << actual_content_with_ending_line
        message << divider("END")
      end

      def failure_message_when_negated
        message = "Expected #{simplified_file_path.inspect}\nnot to "
        message << expectation
        message << "However, it did."
      end

      private

      attr_reader :expected_content, :pathname, :matching_strategy

      def expectation
        message = ""

        if matching_strategy == :stripped_line
          message << "have a stripped line:\n\n"
          message << "  " + expected_content
          message << "\n\n"
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
        pathname.sub(Hashira::Test.project_directory.to_s, "~").to_s
      end

      def actual_stripped_lines
        actual_lines.map(&:strip)
      end

      def actual_lines
        actual_content.split("\n")
      end

      def expected_content_with_ending_line
        if expected_content.end_with?("\n")
          expected_content
        else
          expected_content + "\n"
        end
      end

      def actual_content_with_ending_line
        if actual_content.end_with?("\n")
          actual_content
        else
          actual_content + "\n"
        end
      end

      def actual_content
        @_actual_content ||= pathname.read
      end
    end
  end
end

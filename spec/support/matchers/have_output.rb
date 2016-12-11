module Hashira::Test
  module Matchers
    def have_output(output)
      HaveOutputMatcher.new(output)
    end

    class HaveOutputMatcher
      def initialize(output)
        @output = output
      end

      def matches?(runner)
        @runner = runner
        runner.has_output?(output)
      end

      def failure_message
        "Expected command to output something specific, but it did not.\n\n" +
          "Command: #{runner.formatted_command}\n\n" +
          "Expected output:\n" +
          output.inspect + "\n\n" +
          "Actual output:\n" +
          runner.output
      end

      private

      attr_reader :output, :runner
    end
  end
end

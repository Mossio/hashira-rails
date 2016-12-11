module Hashira::Test
  module Matchers
    def have_configured_variable(variable_name, remote:)
      HaveConfiguredVariableMatcher.new(variable_name, remote)
    end

    class HaveConfiguredVariableMatcher
      def initialize(variable_name, remote_name)
        @variable_name = variable_name
        @remote_name = remote_name
        @matcher = HaveRunCommandsMatcher.new([command])
      end

      def matches?(fake_heroku)
        @fake_heroku = fake_heroku
        matcher.matches?(fake_heroku)
      end

      def failure_message
        "Expected `heroku` to have been used to add an environment " +
          "variable #{variable_name.inspect} for the #{remote_name} " +
          "app,\nbut that didn't happen.\n\n" +
          matcher.failure_message
      end

      private

      attr_reader :variable_name, :remote_name, :matcher

      def command
        /config:add #{variable_name}=.+ --remote #{remote_name}/
      end
    end
  end
end

module Armadura::Test
  module Matchers
    def have_run_commands(commands)
      HaveRunCommandsMatcher.new(commands)
    end

    class HaveRunCommandsMatcher
      def initialize(expected_commands)
        @expected_commands = expected_commands
      end

      def matches?(fake_executable)
        @fake_executable = fake_executable

        expected_commands.all? do |command|
          fake_executable.has_run_command?(command)
        end
      end

      def failure_message
        "Expected `#{fake_executable.executable_name}` to have run these " +
          "commands:\n\n" +
          list_commands(expected_commands) + "\n" +
          "But it ran these commands instead:\n\n" +
          list_commands(actual_commands)
      end

      private

      attr_reader :expected_commands, :fake_executable

      def actual_commands
        fake_executable.commands_run
      end

      def list_commands(commands)
        commands.map { |command| "* #{command.inspect}\n" }.join
      end
    end
  end
end

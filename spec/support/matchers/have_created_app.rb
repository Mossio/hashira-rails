module Hashira::Test
  module Matchers
    def have_created_app(app_name, environment:, flags: "")
      HaveCreatedAppMatcher.new(app_name, environment, flags: flags)
    end

    class HaveCreatedAppMatcher
      def initialize(app_name, environment, flags: "")
        @app_name = app_name
        @environment = environment
        @flags = flags
        @matcher = HaveRunCommandsMatcher.new([command])
      end

      def matches?(fake_heroku)
        @fake_heroku = fake_heroku
        matcher.matches?(fake_heroku)
      end

      def failure_message
        "Expected `heroku` to have been used to create a #{environment} app " +
          "for #{app_name.inspect},\nbut that didn't happen.\n\n" +
          matcher.failure_message
      end

      private

      attr_reader :app_name, :environment, :flags, :matcher, :fake_heroku

      def command
        if flags.empty?
          "create #{full_app_name} --remote #{environment}"
        else
          "create #{full_app_name} #{flags} --remote #{environment}"
        end
      end

      def full_app_name
        "#{app_name}-#{environment}"
      end
    end
  end
end

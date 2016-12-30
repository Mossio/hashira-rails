module Hashira::Test
  module Matchers
    def have_set_up_pipeline_for(app_name)
      HaveSetUpPipelineForMatcher.new(app_name)
    end

    class HaveSetUpPipelineForMatcher
      def initialize(app_name)
        @app_name = app_name
        @matcher = HaveRunCommandsMatcher.new(commands)
      end

      def matches?(fake_heroku)
        @fake_heroku = fake_heroku
        matcher.matches?(fake_heroku)
      end

      def failure_message
        "Expected `heroku` to have been to used to create a pipeline " +
          "consisting of both the staging and production apps,\n" +
          "but that didn't quite happen.\n\n" +
          matcher.failure_message
      end

      private

      attr_reader :app_name, :matcher, :fake_heroku

      def commands
        [
          init_pipeline_with_staging_app_command,
          add_production_app_to_pipeline_command,
        ]
      end

      def init_pipeline_with_staging_app_command
        "pipelines:create #{app_name} --remote staging --stage staging"
      end

      def add_production_app_to_pipeline_command
        "pipelines:add #{app_name} --remote production --stage production"
      end
    end
  end
end

module Hashira::Test
  module Matchers
    def have_created_repo(repo_name)
      HaveCreatedRepoMatcher.new(repo_name)
    end

    class HaveCreatedRepoMatcher
      def initialize(repo_name)
        @repo_name = repo_name
        @matcher = HaveRunCommandsMatcher.new([command])
      end

      def matches?(fake_hub)
        @fake_hub = fake_hub
        matcher.matches?(fake_hub)
      end

      def failure_message
        "Expected `hub` to have been used to create a repo called " +
          "#{repo_name.inspect},\nbut that didn't happen.\n\n" +
          matcher.failure_message
      end

      private

      attr_reader :repo_name, :matcher, :fake_hub

      def command
        "create #{repo_name}"
      end
    end
  end
end

module Hashira::Test
  module Matchers
    def exist
      ExistMatcher.new
    end

    class ExistMatcher
      def matches?(pathname)
        @pathname = pathname
        pathname.exist?
      end

      def failure_message
        "Expected #{simplified_file_path.inspect} to exist, but it did not."
      end

      def failure_message_when_negated
        "Expected #{simplified_file_path.inspect} not to exist, but it did."
      end

      private

      attr_reader :pathname

      def simplified_file_path
        pathname.sub(HashiraTestHelpers.app_directory.to_s, "$APPDIR").to_s
      end
    end
  end
end

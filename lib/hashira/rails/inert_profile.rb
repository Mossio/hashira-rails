module Hashira
  module Rails
    class InertProfile
      def measuring_build(name)
        yield
      end

      def report
      end
    end
  end
end

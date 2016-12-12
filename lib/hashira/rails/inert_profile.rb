module Hashira
  module Rails
    class InertProfile
      def measuring_node(node_type, node_name)
        yield
      end

      def report
      end
    end
  end
end

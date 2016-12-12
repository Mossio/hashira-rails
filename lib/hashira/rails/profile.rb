require 'benchmark'
require 'singleton'

module Hashira
  module Rails
    class Profile
      include Singleton

      YELLOW = "33"
      RED = "31"
      CLEAR = "0"

      def initialize
        @node_stack = []
        @final_node = nil
      end

      def measuring_node(node_type, node_name)
        node_stack << { type: node_type, name: node_name, children: [] }
        result = nil

        time = Benchmark.realtime { result = yield }

        node = node_stack.pop
        node[:time] = time * 1000
        if node_stack.empty?
          @final_node = node
        else
          node_stack.last[:children] << node
        end

        result
      end

      def report
        puts "Profiling report:"
        puts
        puts tree_of_nodes(final_node)
        puts
        puts "Slowest steps:"
        puts
        puts list_of_slowest_steps
      end

      private

      attr_reader :node_stack, :final_node

      def tree_of_nodes(node, level = 0)
        str = ""
        str << " " * (level * 2)
        str << "\e[#{YELLOW}m"

        if level > 0
          str << "* "
        end

        time = "%.1f ms" % node[:time]

        if node[:time] >= 1000
          time =
            "\e[#{CLEAR}m" +
            "\e[#{RED}m" +
            time +
            "\e[#{CLEAR}m" +
            "\e[#{YELLOW}m"
        end

        str << "#{node[:type]} '#{node[:name]}' => #{time}"
        str << "\e[#{CLEAR}m"
        str << "\n"

        node[:children].each do |child|
          str << tree_of_nodes(child, level + 1)
        end

        str
      end

      def list_of_slowest_steps
        leaves_among(final_node).
          select { |node| node[:time] >= 1000 }.
          sort { |a, b| b[:time] <=> a[:time] }.
          map { |node|
            "\e[#{RED}m* %s '%s' => %.1f ms\e[#{CLEAR}m\n" % [
              node[:type],
              node[:name],
              node[:time],
            ]
          }.
          join
      end

      def leaves_among(node)
        if node[:children].any?
          node[:children].flat_map { |child| leaves_among(child) }
        else
          [node]
        end
      end
    end
  end
end

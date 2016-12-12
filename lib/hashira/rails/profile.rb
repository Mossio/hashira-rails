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
        @builds = []
      end

      def measuring_build(name)
        result = nil
        time = Benchmark.realtime { result = yield }
        builds << { name: name, time: time * 1000 }
        result
      end

      def report
        puts "Profiling report:"
        puts
        puts list_of_builds
        puts
        puts "Slowest steps:"
        puts
        puts list_of_slowest_builds
      end

      private

      attr_reader :builds

      def list_of_builds
        builds.map { |build| generate_build_list_item(build) }.join
      end

      def list_of_slowest_builds
        builds.
          select { |build| build[:time] >= 1000 }.
          sort { |a, b| b[:time] <=> a[:time] }.
          map { |build| generate_build_list_item(build) }.
          join
      end

      def generate_build_list_item(build)
        str = ""
        str << "\e[#{YELLOW}m"
        str << "* "

        time = "%.1f ms" % build[:time]

        if build[:time] >= 1000
          time =
            "\e[#{CLEAR}m" +
            "\e[#{RED}m" +
            time +
            "\e[#{CLEAR}m" +
            "\e[#{YELLOW}m"
        end

        str << "#{build[:name]} => #{time}"
        str << "\e[#{CLEAR}m"
        str << "\n"

        str
      end
    end
  end
end

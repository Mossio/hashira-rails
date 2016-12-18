module Hashira
  module Rails
    class CleanUpSpacingIn
      def self.call(file_path)
        new(file_path).call
      end

      def initialize(file_path)
        @file_path = file_path
      end

      def call
        lines = File.readlines(file_path)
        tree = build_tree_from(lines)
        content = stringify_tree(tree).strip
        File.write(file_path, content)
      end

      private

      attr_reader :file_path

      def build_tree_from(lines)
        block_stack = [[]]

        lines.each do |line|
          if start_of_block?(line)
            block_stack << [line]
          elsif end_of_block?(line)
            block_stack.last << line
            group = block_stack.pop
            block_stack.last << group
          else
            block_stack.last << line
          end
        end

        block_stack.last
      end

      def start_of_block?(line)
        line =~ /\bdo$/ || line =~ /^[ ]*(?:if|unless|while|class|module)\b/
      end

      def end_of_block?(line)
        line =~ /\bend$/
      end

      def stringify_tree(tree)
        content = ""

        tree.each_with_index do |node, index|
          if node.is_a?(Array)
            if index > 1
              content << "\n"
            end

            content << stringify_tree(node)

            if index < (node.length - 2)
              content << "\n"
            end
          elsif node != "\n"
            content << node
          end
        end

        content
      end
    end
  end
end

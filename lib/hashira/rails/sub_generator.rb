module Hashira
  module Rails
    class SubGenerator < ::Rails::Generators::AppBase
      TEMPLATES_DIRECTORY = File.expand_path(
        "../../../../templates",
        __FILE__,
      )

      def self.inherited(subclass)
        subclass.source_root(TEMPLATES_DIRECTORY)

        # Thor runs commands in the order that they were defined,
        # so define this method dynamically so as to place it after any
        # methods that the subclass may already have
        subclass.class_eval do
          def run_after_bundle_callbacks
            @after_bundle_callbacks.each(&:call)
          end
        end
      end

      attr_writer :parent_generator

      protected

      attr_reader :parent_generator

      def after_bundle(&block)
        if parent_generator
          parent_generator.after_bundle(&block)
        else
          super
        end
      end
    end
  end
end

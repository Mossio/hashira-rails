module Hashira
  module Rails
    module Actions
      private

      def rename_file(old_path, new_path, options = {})
        action RenameFile.new(self, old_path, new_path, options)
      end

      class RenameFile
        def initialize(base, old_path, new_path, options = {})
          @base = base
          @full_old_path = File.expand_path(old_path, base.destination_root)
          @relative_old_path =
            base.relative_to_original_destination_root(@full_old_path)
          @full_new_path = File.expand_path(new_path, base.destination_root)
          @relative_new_path =
            base.relative_to_original_destination_root(@full_new_path)
          @options = base.options.merge(verbose: true).merge(options)
        end

        def invoke!
          with_no_conflicts do
            FileUtils.mv(full_old_path, full_new_path)
          end
        end

        def revoke!
          say_status :unrename, :red

          if !pretend? && new_path_exists?
            FileUtils.mv(full_new_path, full_old_path)
          end
        end

        private

        attr_reader :base, :full_old_path, :relative_old_path, :full_new_path,
          :relative_new_path, :options

        def pretend?
          options[:pretend]
        end

        def force?
          options[:force]
        end

        def skip?
          options[:skip]
        end

        def verbose?
          options[:verbose]
        end

        def new_path_exists?
          File.exist?(full_new_path)
        end

        def with_no_conflicts(&block)
          if new_path_exists?
            handle_conflict(force?, skip?, &block)
          else
            say_status :rename, :green

            unless pretend?
              yield
            end
          end
        end

        def handle_conflict(force, skip, &block)
          if force
            say_status :force, :yellow

            unless pretend?
              yield
            end
          elsif skip
            say_status :skip, :yellow
          else
            say_status :conflict, :red
            handle_conflict(wants_to_force?, true, &block)
          end
        end

        def wants_to_force?
          base.shell.file_collision(new_path) do
            File.read(full_new_path)
          end
        end

        def say_status(status, color)
          if verbose?
            base.shell.say_status(
              status,
              "#{relative_old_path} -> #{relative_new_path}",
              color,
            )
          end
        end
      end
    end
  end
end

require "English"
require "fileutils"

def FakeExecutable(executable_name, &block)
  Class.new(FakeExecutable, &block).new(executable_name)
end

class FakeExecutable
  TEMP_DIRECTORY = File.expand_path("../../../tmp", __FILE__)

  attr_reader :executable_name

  def initialize(executable_name)
    @executable_name = executable_name
    FileUtils.mkdir_p(TEMP_DIRECTORY)
    @command_log_file = File.join(
      TEMP_DIRECTORY,
      "#{executable_name}_commands",
    )
    open_command_log_for_writing
  end

  def run(args)
    if mode != :write
      raise "#{executable_name} is in #{mode} mode, cannot write"
    end

    command_log.puts args.join(" ")
  end

  def clear
    FileUtils.rm(command_log_file)
    open_command_log_for_writing
  end

  def has_run_command?(command_name_or_pattern)
    commands_run.any? do |command_run|
      command_name_or_pattern === command_run
    end
  end

  def commands_run
    if @commands_run
      @commands_run
    else
      @mode = :read
      @commands_run = command_log.read.split($INPUT_RECORD_SEPARATOR)
    end
  end

  private

  attr_reader :command_log_file, :command_log, :mode

  def open_command_log_for_writing
    @command_log = File.open(command_log_file, "a+")
    @command_log.sync = true
    @mode = :write
    @commands_run = nil
  end
end

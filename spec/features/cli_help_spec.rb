require "spec_helper"

RSpec.xdescribe "Command line help output", type: :feature do
  # before(:all) do
    # @command = HashiraTestHelpers.run_hashira_rails_command!("--help")
  # end

  attr_reader :command

  it "does not contain the default rails usage statement" do
    expect(command).not_to have_output(
      "rails new APP_PATH [options]"
    )
  end

  it "provides the correct usage statement for hashira-rails" do
    expect(command).to have_output(<<~EOH)
      Usage:
        hashira-rails APP_PATH [options]
    EOH
  end

  it "does not contain the default rails group" do
    expect(command).not_to have_output("Rails options:")
  end

  it "provides help and version usage within the hashira group" do
    expect(command).to have_output(<<~EOH)
Hashira options:
  -h, [--help], [--no-help]        # Show this help message and quit
  -v, [--version], [--no-version]  # Show hashira-rails version number and quit
EOH
  end

  it "does not show the default extended rails help section" do
    expect(command).not_to have_output(
      "Create hashira-rails files for app generator."
    )
  end

  it "contains the usage statement from this gem" do
    expect(command).to have_output(usage_file_content)
  end

  def usage_file_content
    Hashira::Test.project_directory.join("USAGE").read
  end
end

require "spec_helper"

RSpec.describe "Command line help output" do
  let(:help_text) { armadura_help_command }

  it "does not contain the default rails usage statement" do
    expect(help_text).not_to include("rails new APP_PATH [options]")
  end

  it "provides the correct usage statement for armadura" do
    expect(help_text).to include <<~EOH
      Usage:
        armadura APP_PATH [options]
    EOH
  end

  it "does not contain the default rails group" do
    expect(help_text).not_to include("Rails options:")
  end

  it "provides help and version usage within the armadura group" do
    expect(help_text).to include <<~EOH
Armadura options:
  -h, [--help], [--no-help]        # Show this help message and quit
  -v, [--version], [--no-version]  # Show Armadura version number and quit
EOH
  end

  it "does not show the default extended rails help section" do
    expect(help_text).not_to include("Create armadura files for app generator.")
  end

  it "contains the usage statement from the armadura gem" do
    expect(help_text).to include IO.read(usage_file)
  end
end

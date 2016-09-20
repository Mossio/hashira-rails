require "spec_helper"

RSpec.describe "Teaspoon" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_armadura
    setup_app_dependencies
  end

  it "adds the Teaspoon gem to the Gemfile" do
    gemfile = IO.read("#{project_path}/Gemfile")
    expect(gemfile).to include "teaspoon"
  end

  it "creates spec/javascripts" do
    expect(File.exist?("#{project_path}/spec/javascripts")).to be true
  end
end

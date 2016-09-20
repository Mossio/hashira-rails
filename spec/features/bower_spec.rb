require "spec_helper"

RSpec.describe "Bower" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_armadura
    setup_app_dependencies
  end

  it "adds the Bower gem to the Gemfile" do
    gemfile = IO.read("#{project_path}/Gemfile")
    expect(gemfile).to include "bower"
  end

  it "adds a bower.json file to the project" do
    expect(File.exist?("#{project_path}/bower.json")).to be true
  end

  it "adds a .bowerrc file to the project" do
    expect(File.exist?("#{project_path}/.bowerrc")).to be true
  end
end

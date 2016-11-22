require "spec_helper"

RSpec.describe "Bower", type: :feature do
  before(:all) do
    generate_app
  end

  it "adds the Bower gem to the Gemfile" do
    expect_app_to_list_gem("bower")
  end

  it "adds a bower.json file to the project" do
    expect(file_in_app("bower.json")).to exist
  end

  it "adds a .bowerrc file to the project" do
    expect(file_in_app(".bowerrc")).to exist
  end
end

require "spec_helper"

RSpec.describe "Teaspoon", type: :feature do
  before(:all) do
    generate_app
  end

  it "adds the Teaspoon gem to the Gemfile" do
    expect_app_to_list_gem("teaspoon")
  end

  it "creates spec/javascripts" do
    expect(directory_in_app("spec/javascripts")).to exist
  end
end

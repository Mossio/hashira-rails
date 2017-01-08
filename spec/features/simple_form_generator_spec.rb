require "spec_helper"

RSpec.describe "The Simple Form generator", type: :feature do
  before(:all) do
    run_hashira_generator(:simple_form)
  end

  it "adds the simple_form gem to the Gemfile" do
    expect(gemfile).to list_gem("simple_form")
  end

  it "runs the Simple Form install generator" do
    expect(file_in_app("config/initializers/simple_form.rb")).to exist
  end
end

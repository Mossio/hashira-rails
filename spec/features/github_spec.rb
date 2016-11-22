require "spec_helper"

RSpec.describe "GitHub", type: :feature do
  before(:all) do
    generate_app("--github=test-repo")
  end

  it "suspends a project with --github option" do
    expect(FakeGithub).to have_created_repo("test-repo")
  end
end

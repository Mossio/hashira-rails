require "spec_helper"

RSpec.describe "The GitHub repo generator", "not given an explicit repo name", type: :feature do
  before(:all) do
    run_hashira_generator(:github_repo, app_name: "some-app")
  end

  it "creates a GitHub repo for the app" do
    expect(FakeGithub).to have_created_repo("some-app")
  end
end

RSpec.describe "The GitHub repo generator", "given an explicit repo name", type: :feature do
  before(:all) do
    run_hashira_generator(:github_repo, repo_name: "custom-repo")
  end

  it "creates a GitHub repo for the app with the given name" do
    expect(FakeGithub).to have_created_repo("custom-repo")
  end
end

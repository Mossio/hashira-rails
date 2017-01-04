require "spec_helper"

RSpec.describe "The stylesheets generator", type: :feature do
  before(:all) do
    run_hashira_generator(:stylesheets)
  end

  it "adds normalize, bourbon, neat, and bitters to the Gemfile" do
    expect(gemfile).to list_gem("normalize-rails")
    expect(gemfile).to list_gem("bourbon", version: "5.0.0.beta.7")
    expect(gemfile).to list_gem("neat")
    expect(gemfile).to list_gem("bitters", group: :development)
  end

  it "installs base stylesheets" do
    expect(directory_in_app("app/assets/stylesheets/base")).to exist
    expect(file_in_app("app/assets/stylesheets/base/_index.scss")).to exist
  end

  it "replaces application.css with application.scss" do
    expect(file_in_app("app/assets/stylesheets/application.css")).not_to exist
    expect(file_in_app("app/assets/stylesheets/application.scss")).to exist
  end

  it "adds an index file for components" do
    expect(file_in_app("app/assets/stylesheets/components/_index.scss")).
      to exist
  end

  it "adds an index file for modules" do
    expect(file_in_app("app/assets/stylesheets/modules/_index.scss")).
      to exist
  end
end

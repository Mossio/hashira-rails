require "spec_helper"

RSpec.describe "The rack-timeout generator", type: :feature do
  before(:all) do
    run_hashira_generator(:rack_timeout)
  end

  it "adds the rack-timeout gem to the Gemfile" do
    expect(gemfile).to list_gem("rack-timeout")
  end

  it "configures the production environment to set a timeout" do
    expect(file_in_app("config/environments/production.rb")).to contain_line(
      'Rack::Timeout.timeout = ENV.fetch("RACK_TIMEOUT", 10).to_i'
    )
  end
end

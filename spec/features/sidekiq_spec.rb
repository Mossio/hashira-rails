require "spec_helper"

RSpec.describe "Sidekiq" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_armadura
    setup_app_dependencies
  end

  it "adds Sidekiq to the Gemfile" do
    gemfile = IO.read("#{project_path}/Gemfile")
    expect(gemfile).to include("sidekiq")
  end

  it "creates a config/sidekiq.yml file configured with the default and mailers queues" do
    sidekiq_config_file = "#{project_path}/config/sidekiq.yml"
    expect(File.exist?(sidekiq_config_file)).to be true
    expect(File.read(sidekiq_config_file)).to include "- default"
    expect(File.read(sidekiq_config_file)).to include "- mailers"
  end

  it "configures ActiveJob to use Sidekiq" do
    application_config = IO.read("#{project_path}/config/application.rb")

    expect(application_config).to include(
      "config.active_job.queue_adapter = :sidekiq"
    )
  end
end

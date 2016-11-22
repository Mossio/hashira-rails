require "spec_helper"

RSpec.describe "Sidekiq", type: :feature do
  before(:all) do
    generate_app
  end

  it "adds Sidekiq to the Gemfile" do
    expect_app_to_list_gem("sidekiq")
  end

  it "creates a config/sidekiq.yml file configured with the default and mailers queues" do
    sidekiq_config_file = file_in_app("config/sidekiq.yml")
    expect(sidekiq_config_file).to exist
    expect(sidekiq_config_file).to contain_line("- default")
    expect(sidekiq_config_file).to contain_line("- mailers")
  end

  it "configures ActiveJob to use Sidekiq" do
    expect(file_in_app("config/application.rb")).
      to contain_line("config.active_job.queue_adapter = :sidekiq")
  end
end

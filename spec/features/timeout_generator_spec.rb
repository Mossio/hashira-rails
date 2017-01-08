require "spec_helper"

RSpec.describe "The timeout generator", type: :feature do
  before(:all) do
    run_hashira_generator(:timeout)
  end

  it "adds the rack-timeout gem to the Gemfile" do
    expect(gemfile).to list_gem("rack-timeout", group: :production)
  end

  it "configures the production environment to set a timeout" do
    production_file = file_in_app("config/environments/production.rb")

    expect(production_file).to contain_text(<<~TEXT.strip)
        config.active_record.dump_schema_after_migration = false
      end

      Rack::Timeout.timeout = ENV.fetch("RACK_TIMEOUT", 10).to_i
    TEXT
  end
end

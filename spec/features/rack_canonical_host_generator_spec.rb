require "spec_helper"

RSpec.describe "The rack-canonical-host generator", type: :feature do
  before(:all) do
    run_hashira_generator(:rack_canonical_host)
  end

  it "adds the rack-canonical-host gem to the Gemfile" do
    expect(gemfile).to list_gem("rack-canonical-host", group: :production)
  end

  it "adds the middleware in the production environment" do
    production_file = file_in_app("config/environments/production.rb")

    expect(production_file).to contain_text(<<~TEXT.rstrip)
          config.logger = ActiveSupport::TaggedLogging.new(logger)
        end

        config.active_record.dump_schema_after_migration = false
        config.middleware.use Rack::CanonicalHost, ENV.fetch("APPLICATION_HOST")
      end
    TEXT
  end
end

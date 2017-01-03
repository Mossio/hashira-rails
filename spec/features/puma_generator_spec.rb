require "spec_helper"

RSpec.describe "The Puma generator", type: :feature do
  before(:all) do
    run_hashira_generator(:puma)
  end

  it "replaces the configuration file for Puma" do
    puma_config_file = file_in_app("config/puma.rb")
    expect(puma_config_file).to contain_text(<<~CONTENT.strip)
      threads_count = Integer(ENV.fetch("MAX_THREADS", 2))
      threads(threads_count, threads_count)
      workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
    CONTENT
    expect(puma_config_file).to contain_text(
      "on_worker_boot { ActiveRecord::Base.establish_connection }"
    )
  end

  it "adds WEB_CONCURRENCY to .env.example" do
    expect(file_in_app(".env.example")).to contain_line("WEB_CONCURRENCY=1")
  end

  context "if the Procfile is not present" do
    it "adds a 'web' line to the Procfile" do
      expect(file_in_app("Procfile")).to contain_text(<<~CONTENT, match: :exact)
        web: bundle exec puma -C config/puma.rb
      CONTENT
    end
  end
end

RSpec.describe "The Puma generator", "if the Procfile is present", type: :feature do
  before(:all) do
    run_hashira_generator(:puma) do
      file_in_app("Procfile").write(<<~CONTENT)
        web: whatever
        something: else
      CONTENT
    end
  end

  it "replaces the 'web' line in the Procfile" do
    expect(file_in_app("Procfile")).to contain_text(<<~CONTENT, match: :exact)
      web: bundle exec puma -C config/puma.rb
      something: else
    CONTENT
  end
end

require "spec_helper"

RSpec.describe "The core generator", type: :feature do
  before(:all) do
    run_hashira_generator(:core, app_name: "some_app")
  end

  it "puts dotfiles in place" do
    expect(file_in_app(".ctags")).to exist
    expect(file_in_app(".env")).to exist
  end

  it "configures the app to use the same Ruby version that the gem does" do
    expect(gemfile).to declare_ruby_version(Hashira::Rails::RUBY_VERSION)
    expect(file_in_app(".ruby-version")).
      to contain_text("#{Hashira::Rails::RUBY_VERSION}\n", match: :exact)
  end

  it "uses Rails #{Hashira::Rails::RAILS_VERSION}" do
    expect(gemfile).to list_gem("rails", version: Hashira::Rails::RAILS_VERSION)
  end

  it "removes jbuilder from the Gemfile" do
    expect(gemfile).not_to list_gem("jbuilder")
  end

  # it "replaces byebug with pry-byebug" do
    # expect(gemfile).not_to list_gem("byebug")
    # expect(gemfile).to list_gem("pry-byebug", group: [:development, :test])
  # end

  # it "configures the app to use Postgres instead of SQLite and replaces database.yml to match" do
    # expect(gemfile).not_to list_gem("sqlite")
    # expect(gemfile).to list_gem("pg")
    # expect(file_in_app("config/database.yml")).
      # to contain_text("adapter: postgresql")
  # end

  # it "removes Listen" do
  # expect(gemfile).not_to list_gem("listen")
  # expect(gemfile).not_to list_gem("spring-watcher-listen")
    # expect(file_in_app("config/environments/development.rb")).
      # not_to contain_line(
        # "config.file_watcher = ActiveSupport::EventedFileUpdateChecker",
      # )
  # end

  # it "removes Turbolinks from the app" do
  # expect(gemfile).not_to list_gem("turbolinks")

    # expect(file_in_app("app/assets/javascripts/application.js")).
      # not_to contain_line("//= require turbolinks")
  # end

  # it "adds RecipientInterceptor" do
  # expect(gemfile).to list_gem("recipient_interceptor")
    # expect(file_in_app("config/smtp.rb")).
      # to contain_text %(RecipientInterceptor.new(ENV["EMAIL_RECIPIENTS"]))
    # # Note: This requires Heroku! We might just want to iterate through
    # # .env.example to add this
    # expect(file_in_app("app.json")).
      # to contain_text %("EMAIL_RECIPIENTS":)
  # end

  it "replaces the README" do
    readme = file_in_app("README.md")
    ruby_version = Hashira::Rails::RUBY_VERSION

    expect(readme).to contain_text("# Some App")
    expect(readme).to contain_text("you will need to have Ruby #{ruby_version}")
    expect(readme).to contain_text("you can install Ruby #{ruby_version}")
    expect(readme).to contain_text("rbenv install #{ruby_version}")
  end

  it "replaces the setup script" do
    expect(file_in_app("bin/setup")).
      to contain_text("=== Ensuring current Ruby version is installed ===")
    expect(file_in_app("bin/setup")).to be_executable
  end

  it "adds useful date and time formats to the translations file" do
    expect(file_in_app("config/locales/en.yml")).to contain_text(<<-TEXT)
  date:
    formats:
      full: "%B %-d, %Y"
      shorter: "%b %-d, %Y"
      full_without_year: "%B %-d"
      shorter_without_year: "%b %-d"
      standard: "%-m/%-d/%Y"
      standard_without_year: "%-m/%-d"
  time:
    formats:
      full: "%B %-d, %Y at %-I:%M %p"
      shorter: "%b %-d, %Y at %-I:%M %p"
      standard: "%-m/%-d/%Y, %-I:%M%P"
    TEXT
  end

  it "disables wrap_parameters behavior" do
    expect(file_in_app("config/initializers/wrap_parameters.rb")).not_to exist
  end

  it "customizes the error pages" do
    [404, 422, 500].each do |page|
      expect(file_in_app("public/#{page}.html")).
        to contain_text %(<meta charset="utf-8" />)
      expect(file_in_app("public/#{page}.html")).
        to contain_text %(<meta name="ROBOTS" content="NOODP" />)
    end
  end

  it "removes comments from various config files" do
    config_files = [
      "config/application.rb",
      "config/environment.rb",
      "config/environments/development.rb",
      "config/environments/production.rb",
      "config/environments/test.rb",
    ]

    config_files.each do |file|
      expect(file_in_app(file)).not_to contain_line(/^[ ]*#/)
    end
  end

  it "configures ActionMailer in dev and prod not to swallow delivery errors" do
    expect(file_in_app("config/environments/development.rb")).
      to contain_line("config.action_mailer.raise_delivery_errors = true")
    expect(file_in_app("config/environments/production.rb")).
      to contain_line("config.action_mailer.raise_delivery_errors = true")
  end

  it "configures ActionMailer in development to log sent emails to files" do
    expect(file_in_app("config/environments/development.rb")).to contain_line(
      "config.action_mailer.delivery_method = :file",
    )
  end

  it "configures SMTP settings for ActionMailer in production" do
    production_environment_file =
      file_in_app("config/environments/production.rb")

    expect(file_in_app("config/smtp.rb")).to exist
    expect(production_environment_file).
      to contain_line %(require Rails.root.join("config/smtp.rb"))
    expect(production_environment_file).
      to contain_line("config.action_mailer.delivery_method = :smtp")
    expect(production_environment_file).
      to contain_line("config.action_mailer.smtp_settings = SMTP_SETTINGS")
  end

  it "adds tasks and supporting files to seed the database" do
    expect(file_in_app("lib/tasks/dev.rake")).to exist
    expect(file_in_app("lib/development_soil.rb")).to exist
  end

  it "configures ActiveJob to use the inline adapter in tests" do
    expect(file_in_app("config/environments/test.rb")).to contain_line(
      "config.active_job.queue_adapter = :inline",
    )
  end

  it "initializes the git repo" do
    expect(directory_in_app(".git")).to exist
  end
end

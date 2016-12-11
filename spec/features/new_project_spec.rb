require "spec_helper"

RSpec.describe "Suspend a new project with default configuration", type: :feature do
  before(:all) do
    generate_app
  end

  it "uses custom Gemfile" do
    expect(gemfile).to contain_line %(ruby "#{Hashira::Rails::RUBY_VERSION}")
    expect_app_to_list_gem("autoprefixer-rails")
    expect_app_to_list_gem("rails", version: Hashira::Rails::RAILS_VERSION)
  end

  it "ensures project specs pass" do
    expect(run_command_within_app!("rake")).
      to have_output("0 failures")
  end

  it "creates .ruby-version from Hashira .ruby-version" do
    expect(file_in_app(".ruby-version")).
      to contain_text("#{Hashira::Rails::RUBY_VERSION}\n", match: :exact)
  end

  it "copies dotfiles" do
    expect(file_in_app(".ctags")).to exist
    expect(file_in_app(".env")).to exist
  end

  it "loads secret_key_base from env" do
    expect(file_in_app("config/secrets.yml")).
      to contain_text %(secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>)
  end

  it "adds bin/setup file" do
    expect(file_in_app("bin/setup")).to exist
  end

  it "makes bin/setup executable" do
    expect(file_in_app("bin/setup")).to be_executable
  end

  it "adds support file for action mailer" do
    expect(file_in_app("spec/support/action_mailer.rb")).to exist
  end

  it "configures capybara-webkit" do
    expect(file_in_app("spec/support/capybara_webkit.rb")).to exist
  end

  it "adds support file for i18n" do
    expect(file_in_app("spec/support/i18n.rb")).to exist
  end

  it "creates good default .hound.yml" do
    expect(file_in_app(".hound.yml")).to contain_text("enabled: true")
  end

  it "ensures Gemfile contains `rack-mini-profiler`" do
    expect_app_to_list_gem("rack-mini-profile", require: false)
  end

  it "ensures .sample.env defaults to RACK_MINI_PROFILER=0" do
    expect(file_in_app(".env")).
      to contain_text("RACK_MINI_PROFILER=0", match: :line)
  end

  it "creates a rack-mini-profiler initializer" do
    expect(file_in_app("config/initializers/rack_mini_profiler.rb")).to exist
  end

  it "records pageviews through Segment if ENV variable set" do
    analytics_partial = file_in_app("app/views/application/_analytics.html.erb")

    expect(analytics_partial).
      to contain_text %(<% if ENV["SEGMENT_KEY"] %>)
    expect(analytics_partial).
      to contain_text %(window.analytics.load("<%= ENV["SEGMENT_KEY"] %>");)
  end

  it "raises on unpermitted parameters in all environments" do
    expect(file_in_app("config/application.rb")).to contain_line(
      "config.action_controller.action_on_unpermitted_parameters = :raise",
    )
  end

  it "adds explicit quiet_assets configuration" do
    expect(file_in_app("config/application.rb")).to contain_line(
      "config.assets.quiet = true",
    )
  end

  it "configures public_file_server.headers in production" do
    expect(production_environment_config_file).to contain_text(
      /^[ ]+config\.public_file_server\.headers = {\s+"Cache-Control" => "public,/,
    )
  end

  it "raises on missing translations in development and test" do
    environment_config_files = [
      development_environment_config_file,
      test_environment_config_file,
    ]

    environment_config_files.each do |environment_file|
      expect(environment_file).to contain_line(
        "config.action_view.raise_on_missing_translations = true",
      )
    end
  end

  it "evaluates en.yml.erb" do
    expect(file_in_app("config/locales/en.yml")).to contain_line(
      "application: #{app_name.humanize}",
    )
  end

  it "configs simple_form" do
    expect(file_in_app("config/initializers/simple_form.rb")).to exist
  end

  it "configs :test email delivery method for development" do
    expect(development_environment_config_file).to contain_line(
      "config.action_mailer.delivery_method = :file",
    )
  end

  it "uses APPLICATION_HOST, not HOST in the production config" do
    expect(production_environment_config_file).
      to contain_text(/"APPLICATION_HOST"/)
    expect(production_environment_config_file).
      not_to contain_text(/"HOST"/)
  end

  it "configures email interceptor in smtp config" do
      expect(file_in_app("config/smtp.rb")).
      to contain_text %(RecipientInterceptor.new(ENV["EMAIL_RECIPIENTS"]))
  end

  it "configures language in html element" do
    expect(file_in_app("app/views/layouts/application.html.erb")).
      to contain_text %(<html lang="en">)
  end

  it "configures the test environment to process queues inline" do
    expect(test_environment_config_file).to contain_line(
      "config.active_job.queue_adapter = :inline",
    )
  end

  it "configs bullet gem in development" do
    expect(development_environment_config_file).to contain_line(
      "Bullet.enable = true",
    )
    expect(development_environment_config_file).to contain_line(
      "Bullet.bullet_logger = true",
    )
    expect(development_environment_config_file).to contain_line(
      "Bullet.rails_logger = true",
    )
  end

  it "configs missing assets to raise in test" do
    expect(test_environment_config_file).to contain_line(
      "config.assets.raise_runtime_errors = true",
    )
  end

  it "adds spring to binstubs" do
    expect(file_in_app("bin/spring")).to exist

    ["rake", "rails", "spring"].each do |executable|
      expect(file_in_app("bin/#{executable}")).to contain_text("spring")
    end
  end

  it "removes comments and extra newlines from config files" do
    config_files = [
      file_in_app("config/application.rb"),
      file_in_app("config/environment.rb"),
      development_environment_config_file,
      test_environment_config_file,
      production_environment_config_file,
    ]

    config_files.each do |file|
      expect(file).not_to contain_text(/.*#.*/)
      expect(file).not_to contain_text(/^$\n/)
    end
  end

  it "copies factories.rb" do
    expect(file_in_app("spec/factories.rb")).to exist
  end

  it "creates review apps setup script" do
    setup_review_app_file = file_in_app("bin/setup_review_app")

    expect(setup_review_app_file).to contain_line(
      "heroku run rake db:migrate --exit-code --app #{app_name.dasherize}-staging-pr-$1"
    )
    expect(setup_review_app_file).to contain_line(
      "heroku ps:scale worker=1 --app #{app_name.dasherize}-staging-pr-$1"
    )
    expect(setup_review_app_file).to contain_line(
      "heroku restart --app #{app_name.dasherize}-staging-pr-$1"
    )
    expect(setup_review_app_file).to be_executable
  end

  it "creates deploy script" do
    deploy_script = file_in_app("bin/deploy")

    expect(deploy_script).
      to contain_text("heroku run rake db:migrate --exit-code")
    expect(deploy_script).to be_executable
  end

  it "creates heroku application manifest file with application name in it" do
    expect(file_in_app("app.json")).
      to contain_text %("name":"#{app_name.dasherize}")
  end

  it "sets up heroku specific gems" do
    expect_app_to_list_gem("rails_stdout_logging")
  end

  it "adds high_voltage" do
    expect_app_to_list_gem("high_voltage")
  end

  it "adds and configures bourbon, neat, and refills" do
    expect_app_to_list_gem("bourbon")
    expect_app_to_list_gem("neat")
    expect_app_to_list_gem("refills")
  end

  it "configures bourbon, neat, and refills" do
    flashes_partial =
      file_in_app("app/assets/stylesheets/refills/_flashes.scss")
    application_sass_file =
      file_in_app("app/assets/stylesheets/application.scss")

    expect(flashes_partial).to contain_text("flashes")
    expect(application_sass_file).
      to contain_text(/normalize-rails/, match: :line)
    expect(application_sass_file).to contain_text(/bourbon/, match: :line)
    expect(application_sass_file).to contain_text(/neat/, match: :line)
    expect(application_sass_file).to contain_text(/base/, match: :line)
    expect(application_sass_file).to contain_text(/refills/, match: :line)
  end

  it "doesn't use turbolinks" do
    expect(file_in_app("app/assets/javascripts/application.js")).
      not_to contain_line("//= require turbolinks")
  end

  it "removes the test directory" do
    expect(directory_in_app("test")).not_to exist
  end

  def app_name
    HashiraTestHelpers::APP_NAME
  end

  def gemfile
    file_in_app("Gemfile")
  end

  def development_environment_config_file
    file_in_app("config/environments/development.rb")
  end

  def test_environment_config_file
    file_in_app("config/environments/test.rb")
  end

  def production_environment_config_file
    file_in_app("config/environments/production.rb")
  end
end

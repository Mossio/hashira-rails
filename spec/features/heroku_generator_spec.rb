require "spec_helper"

RSpec.describe "The Heroku generator", type: :feature do
  context "regardless of the given Heroku app name" do
    before(:all) do
      run_hashira_generator(
        :heroku,
        app_name: app_name,
        slack_webhook_url: "whatever",
      )
    end

    it "adds app.json to the project" do
      expect(file_in_app("app.json")).to exist
    end

    it "adds a deploy script to the project" do
      script = file_in_app("bin/deploy")

      expect(script).to exist
      expect(script).to be_executable
    end

    it "generates SECRET_KEY_BASE for both apps" do
      expect(FakeHeroku).to have_configured_variable(
        "SECRET_KEY_BASE",
        remote: "staging",
      )
      expect(FakeHeroku).to have_configured_variable(
        "SECRET_KEY_BASE",
        remote: "production",
      )
    end
  end

  context "using the default Heroku app name" do
    before(:all) do
      run_hashira_generator(
        :heroku,
        app_name: app_name,
        slack_webhook_url: "whatever",
      )
    end

    it "creates staging and production Heroku apps" do
      expect(FakeHeroku).to have_created_app(
        heroku_app_name,
        environment: "staging",
      )
      expect(FakeHeroku).to have_created_app(
        heroku_app_name,
        environment: "production",
      )
    end

    it "generates APPLICATION_HOST for both apps" do
      expect(FakeHeroku).to have_configured_variable(
        "APPLICATION_HOST",
        remote: "staging",
      )
      expect(FakeHeroku).to have_configured_variable(
        "APPLICATION_HOST",
        remote: "production",
      )
    end

    it "creates the Heroku pipeline consisting of both apps" do
      expect(FakeHeroku).to have_set_up_pipeline_for(heroku_app_name)
    end

    it "adds a script so that CircleCI can deploy the app easily" do
      script = file_in_app("bin/deploy_staging_from_circleci")

      expect(script).to exist
      expect(script).to be_executable

      expect(script).to contain_text(<<~TEXT)
        #!/bin/sh

        set -e

        APP="#{heroku_app_name}-staging"

        git remote add heroku "git@heroku.com:${APP}.git"
        git push heroku "${CIRCLE_SHA1}:master"
        heroku run rake db:migrate --app "${APP}"
        heroku restart --app "${APP}"
      TEXT
    end

    def heroku_app_name
      app_name.dasherize
    end
  end

  context "given a custom Heroku app name" do
    before(:all) do
      run_hashira_generator(
        :heroku,
        slack_webhook_url: "whatever",
        heroku_app_name: heroku_app_name,
      )
    end

    it "creates staging and production Heroku apps" do
      expect(FakeHeroku).to have_created_app(
        heroku_app_name,
        environment: "staging",
      )
      expect(FakeHeroku).to have_created_app(
        heroku_app_name,
        environment: "production",
      )
    end

    it "generates APPLICATION_HOST for both apps" do
      expect(FakeHeroku).to have_configured_variable(
        "APPLICATION_HOST",
        remote: "staging",
      )
      expect(FakeHeroku).to have_configured_variable(
        "APPLICATION_HOST",
        remote: "production",
      )
    end

    it "creates the Heroku pipeline consisting of both apps" do
      expect(FakeHeroku).to have_set_up_pipeline_for(heroku_app_name)
    end

    it "adds a script so that CircleCI can deploy the app easily" do
      script = file_in_app("bin/deploy_staging_from_circleci")

      expect(script).to exist
      expect(script).to be_executable

      expect(script).to contain_text(<<~TEXT)
        #!/bin/sh

        set -e

        APP="#{heroku_app_name}-staging"

        git remote add heroku "git@heroku.com:${APP}.git"
        git push heroku "${CIRCLE_SHA1}:master"
        heroku run rake db:migrate --app "${APP}"
        heroku restart --app "${APP}"
      TEXT
    end

    def heroku_app_name
      "custom-app"
    end
  end
end

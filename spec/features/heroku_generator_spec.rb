require "spec_helper"

RSpec.describe "The Heroku generator", "regardless of the given Heroku app name", type: :feature do
  before(:all) do
    run_hashira_generator(:heroku, slack_webhook_url: "whatever")
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

  it "adds a Procfile" do
    expect(file_in_app("Procfile")).to exist
  end
end

RSpec.describe "The Heroku generator", "using the default Heroku app name", type: :feature do
  before(:all) do
    run_hashira_generator(
      :heroku,
      app_name: "some_app",
      slack_webhook_url: "whatever",
    )
  end

  it "creates staging and production Heroku apps" do
    expect(FakeHeroku).to have_created_app(
      "some-app",
      environment: "staging",
    )
    expect(FakeHeroku).to have_created_app(
      "some-app",
      environment: "production",
    )
  end

  it "creates the Heroku pipeline consisting of both apps" do
    expect(FakeHeroku).to have_set_up_pipeline_for("some-app")
  end

  it "adds a script so that CircleCI can deploy the app easily" do
    script = file_in_app("bin/deploy_staging_from_circleci")

    expect(script).to exist
    expect(script).to be_executable

    expect(script).to contain_text(<<~TEXT)
      #!/bin/sh

      set -e

      APP="some-app-staging"

      git remote add heroku "git@heroku.com:${APP}.git"
      git push heroku "${CIRCLE_SHA1}:master"
      heroku run rake db:migrate --app "${APP}"
      heroku restart --app "${APP}"
    TEXT
  end

  it "adds a deployment section to the README" do
    expect(file_in_app("README.md")).to contain_text(<<-TEXT.strip)
## Deployment

There are two versions of the app, staging and production, and they are hosted
on [Heroku].

You will first need to sign up for a Heroku account and be given access to these
apps before you can deploy.

When you have access, run these commands:

    heroku git:remote -r staging -a some-app-staging
    heroku git:remote -r production -a some-app-production

This will let you interact with the staging and production apps from the command
line.

The staging app will be deployed automatically when you push to the `master`
branch. However, if you need to deploy it manually for some reason, you can say:

    bin/deploy staging

And when you want to deploy to production, you can say:

    bin/deploy production

[Heroku]: http://heroku.com
    TEXT
  end
end

RSpec.describe "The Heroku generator", "given a custom Heroku app name", type: :feature do
  before(:all) do
    run_hashira_generator(
      :heroku,
      slack_webhook_url: "whatever",
      heroku_app_name: "custom-app",
    )
  end

  it "creates staging and production Heroku apps" do
    expect(FakeHeroku).to have_created_app(
      "custom-app",
      environment: "staging",
    )
    expect(FakeHeroku).to have_created_app(
      "custom-app",
      environment: "production",
    )
  end

  it "creates the Heroku pipeline consisting of both apps" do
    expect(FakeHeroku).to have_set_up_pipeline_for("custom-app")
  end

  it "adds a script so that CircleCI can deploy the app easily" do
    script = file_in_app("bin/deploy_staging_from_circleci")

    expect(script).to exist
    expect(script).to be_executable

    expect(script).to contain_text(<<~TEXT)
      #!/bin/sh

      set -e

      APP="custom-app-staging"

      git remote add heroku "git@heroku.com:${APP}.git"
      git push heroku "${CIRCLE_SHA1}:master"
      heroku run rake db:migrate --app "${APP}"
      heroku restart --app "${APP}"
    TEXT
  end

  it "adds some additions to the README" do
    expect(file_in_app("README.md")).to contain_text(<<-TEXT)
## Deployment

There are two versions of the app, staging and production, and they are hosted
on [Heroku].

You will first need to sign up for a Heroku account and be given access to these
apps before you can deploy.

When you have access, run these commands:

    heroku git:remote -r staging -a custom-app-staging
    heroku git:remote -r production -a custom-app-production

This will let you interact with the staging and production apps from the command
line.

The staging app will be deployed automatically when you push to the `master`
branch. However, if you need to deploy it manually for some reason, you can say:

    bin/deploy staging

And when you want to deploy to production, you can say:

    bin/deploy production

[Heroku]: http://heroku.com
    TEXT
  end
end

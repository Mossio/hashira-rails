require "hashira/rails/generator_base"

module Hashira
  class HerokuGenerator < Hashira::Rails::GeneratorBase
    class_option :slack_webhook_url,
      required: true,
      desc: "The Slack webhook URL used for making Heroku notifications."

    class_option :heroku_app_name,
      type: :string,
      desc: "The prefix used to name the generated Heroku apps."

    def add_app_json
      template "app.json.erb", "app.json"
    end

    def create_staging_and_production_apps
      run %(heroku create #{heroku_app_name}-staging --remote staging)
      run %(heroku create #{heroku_app_name}-production --remote production)
    end

    def configure_both_apps
      run %(heroku config:set SECRET_KEY_BASE="#{generated_secret_key_base}" --remote staging)
      run %(heroku config:set SECRET_KEY_BASE="#{generated_secret_key_base}" --remote production)
      run %(heroku config:set APPLICATION_HOST="#{heroku_app_name}-staging.herokuapp.com" --remote staging)
      run %(heroku config:set APPLICATION_HOST="#{heroku_app_name}-production.herokuapp.com" --remote production)
    end

    def create_pipeline
      run %(heroku pipelines:create #{heroku_app_name} --remote staging --stage staging)
      run %(heroku pipelines:add #{heroku_app_name} --remote production --stage production)
    end

    def add_deploy_script
      copy_file "bin_deploy", "bin/deploy"
      set_executable "bin/deploy"
    end

    def add_deploy_script_for_circleci
      template "deploy_staging_from_circleci.erb",
        "bin/deploy_staging_from_circleci"
      set_executable "bin/deploy_staging_from_circleci"
    end

    def add_deployment_section_to_readme
      append_to_file "README.md", <<-TEXT

## Deployment

There are two versions of the app, staging and production, and they are hosted
on [Heroku].

You will first need to sign up for a Heroku account and be given access to these
apps before you can deploy.

When you have access, run these commands:

    heroku git:remote -r staging -a #{heroku_app_name}-staging
    heroku git:remote -r production -a #{heroku_app_name}-production

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

    def set_application_host_in_production
      text = <<-TEXT.rstrip


if ENV.fetch("HEROKU_APP_NAME", "").include?("staging-pr-")
  ENV["APPLICATION_HOST"] = ENV["HEROKU_APP_NAME"] + ".herokuapp.com"
end
      TEXT

      insert_into_file "config/environments/production.rb",
        text,
        after: /\nend\Z/
    end

    def add_procfile
      copy_file "Procfile", "Procfile"
    end

    private

    def heroku_app_name
      options.fetch(:heroku_app_name) { app_name.dasherize }
    end

    def generated_secret_key_base
      # This is the same code that runs when you run `rails secret`
      SecureRandom.hex(64)
    end
  end
end

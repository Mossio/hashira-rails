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

    private

    def heroku_app_name
      options.fetch(:heroku_app_name) { app_name.dasherize }
    end

    def app_name
      hashira_config_file = path_to_file(".hashira.json")

      if hashira_config_file.exist?
        JSON.parse(hashira_config_file.read)["app_name"]
      else
        File.basename(destination_root)
      end
    end

    def generated_secret_key_base
      # This is the same code that runs when you run `rails secret`
      SecureRandom.hex(64)
    end
  end
end

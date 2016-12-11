require "spec_helper"

RSpec.describe "Heroku", type: :feature do
  context "--heroku" do
    before(:all) do
      generate_app("--heroku=true")
    end

    it "suspends a project for Heroku" do
      expect(FakeHeroku).
        to have_created_app(app_name, environment: "staging")
      expect(FakeHeroku).
        to have_created_app(app_name, environment: "production")
      expect(FakeHeroku).
        to have_configured_variable("SECRET_KEY_BASE", remote: "staging")
      expect(FakeHeroku).
        to have_configured_variable("SECRET_KEY_BASE", remote: "production")
      expect(FakeHeroku).
        to have_configured_variable("APPLICATION_HOST", remote: "staging")
      expect(FakeHeroku).
        to have_configured_variable("APPLICATION_HOST", remote: "production")
      expect(FakeHeroku).to have_set_up_pipeline_for(app_name)

      setup_script = file_in_app("bin/setup")

      expect(setup_script).
        to contain_text("heroku join --app #{app_name}-production")
      expect(setup_script).
        to contain_text("heroku join --app #{app_name}-staging")
      expect(setup_script).
        to contain_line("git config heroku.remote staging")
      expect(setup_script).to be_executable

      expect(readme).to contain_line("bin/deploy staging")
      expect(readme).to contain_line("bin/deploy production")

      expect(circleci_configuration_file).to contain_text(<<-YML.strip_heredoc)
        deployment:
          staging:
            branch: master
            commands:
              - bin/deploy staging
      YML
    end

    def setup_script
      file_in_app("bin/setup")
    end

    def readme
      file_in_app("README.md")
    end

    def circleci_configuration_file
      file_in_app("circle.yml")
    end
  end

  context "--heroku with region flag" do
    before(:all) do
      generate_app(%(--heroku=true --heroku-flags="--region eu"))
    end

    it "suspends a project with extra Heroku flags" do
      expect(FakeHeroku).to have_created_app(
        app_name,
        environment: "staging",
        flags: "--region eu",
      )
      expect(FakeHeroku).to have_created_app(
        app_name,
        environment: "production",
        flags: "--region eu",
      )
    end
  end

  def app_name
    HashiraTestHelpers::APP_NAME.dasherize
  end
end

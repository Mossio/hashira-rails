require "hashira/rails/generator_base"

module Hashira
  class GithubRepoGenerator < Hashira::Rails::GeneratorBase
    class_option :repo_name,
      type: :string,
      desc: "The name of the GitHub repo that will be created"

    def create_github_repo
      run "hub create #{repo_name}"
    end

    private

    def repo_name
      options.fetch(:repo_name) { app_name.dasherize }
    end
  end
end

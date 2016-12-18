module HashiraTestHelpers
  APP_NAME = "dummy_app".freeze

  extend self

  def remove_app_directory
    FileUtils.rm_rf(app_directory)
  end

  def create_tmp_directory
    tmp_directory.mkpath
  end
  alias_method :create_working_directory, :create_tmp_directory

  def generate_app(*additional_args)
    args = [
      APP_NAME,
      "--path=#{project_directory}",
      "--force",
      *additional_args
    ]

    FakeGithub.clear
    FakeHeroku.clear
    drop_app_database!
    remove_app_directory
    run_hashira_rails_command!(*args)
    install_app_dependencies!
  end

  def run_hashira_rails_command!(*args)
    run_command!(
      hashira_rails_executable_path.to_s,
      *args,
    ) do |runner|
      runner.directory = tmp_directory
    end
  end

  def run_hashira_generator(name, *additional_args)
    args = [
      "--path=#{project_directory}",
      "--force",
      *additional_args,
    ]

    FakeGithub.clear
    FakeHeroku.clear
    drop_app_database!
    copy_existing_app_to_working_directory
    install_app_dependencies!
    run_command!("bin/rails g hashira:#{name}")
  end

  def app_directory
    working_directory.join(APP_NAME)
  end

  def file_in_app(path)
    app_directory.join(path)
  end

  alias_method :directory_in_app, :file_in_app

  def expect_app_to_list_gem(gem_name, version: nil, **options)
    gemfile = file_in_app("Gemfile")
    formatted_options = options.
      map { |key, value| "#{key}: #{value.inspect}" }.
      join(", ")
    pieces = [%(gem "#{gem_name}"), version, formatted_options].
      select { |value| !value.nil? && !value.empty? }
    pieces.join(", ")
  end

  def gemfile
    file_in_app("Gemfile")
  end

  private

  def install_app_dependencies!
    if app_directory.exist?
      if !run_command_within_app("bundle check").success?
        run_command_within_app!("bundle install")
      end
    end
  end

  def copy_existing_app_to_working_directory
    FileUtils.rm_rf(app_directory)
    FileUtils.cp_r(existing_app_directory, app_directory)
  end

  def drop_app_database!
    Hashira::Test::CommandRunner.run!(
      "dropdb --if-exists #{APP_NAME}_development"
    )
    Hashira::Test::CommandRunner.run!(
      "dropdb --if-exists #{APP_NAME}_test"
    )
  end

  def run_command(*args, &block)
    build_command_runner(*args, &block).tap do |runner|
      runner.call
    end
  end
  alias_method :run_command_within_app, :run_command

  def run_command!(*args, &block)
    build_command_runner(*args, &block).tap do |runner|
      runner.run_successfully = true
      runner.call
    end
  end
  alias_method :run_command_within_app!, :run_command!

  def build_command_runner(*args)
    Hashira::Test::CommandRunner.new(*args).tap do |runner|
      runner.directory = app_directory
      runner.env["PATH"] = "#{fake_executables_directory}:#{ENV["PATH"]}"

      yield runner if block_given?

      runner.around_command do |run_command|
        Bundler.with_clean_env(&run_command)
      end
    end
  end

  def tmp_directory
    project_directory.join("tmp")
  end
  alias_method :working_directory, :tmp_directory

  def existing_app_directory
    project_directory.join("spec/support/dummy_app")
  end

  def hashira_rails_executable_path
    project_directory.join("exe/hashira-rails")
  end

  def fake_executables_directory
    project_directory.join("spec/support/fake_executables")
  end

  def project_directory
    Hashira::Test.project_directory
  end
end

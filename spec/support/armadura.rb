module ArmaduraTestHelpers
  APP_NAME = "dummy_app"

  extend self

  def remove_app_directory
    FileUtils.rm_rf(app_directory)
  end

  def create_tmp_directory
    tmp_directory.mkpath
  end

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
    run_armadura_command!(*args)
    install_app_dependencies!
  end

  def run_armadura_command!(*args)
    run_command!(
      armadura_executable_path.to_s,
      *args,
    )
  end

  def run_command_within_app(*args)
    run_command(*args) do |runner|
      runner.directory = app_directory
    end
  end

  def run_command_within_app!(*args)
    run_command!(*args) do |runner|
      runner.directory = app_directory
    end
  end

  def app_directory
    tmp_directory.join(APP_NAME)
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

  private

  def install_app_dependencies!
    if app_directory.exist?
      if !run_command_within_app("bundle check").success?
        run_command_within_app!("bundle install")
      end
    end
  end

  def drop_app_database!
    if app_directory.exist?
      run_command_within_app!("bundle exec rake db:drop")
    end
  end

  def run_command(*args, &block)
    build_command_runner(*args, &block).tap do |runner|
      runner.call
    end
  end

  def run_command!(*args, &block)
    build_command_runner(*args, &block).tap do |runner|
      runner.run_successfully = true
      runner.call
    end
  end

  def build_command_runner(*args)
    Armadura::Test::CommandRunner.new(*args).tap do |runner|
      runner.directory = tmp_directory
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

  def armadura_executable_path
    project_directory.join("exe/armadura")
  end

  def fake_executables_directory
    project_directory.join("spec/fakes/bin")
  end

  def project_directory
    Armadura::Test.project_directory
  end
end

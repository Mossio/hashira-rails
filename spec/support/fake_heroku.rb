require_relative "fake_executable"

FakeHeroku = FakeExecutable(:heroku) do
  def run(args)
    if args.first == "help"
      puts "pipelines      #  manage collections of apps in pipelines"
    end

    super
  end

  def self.has_gem_included?(project_path, gem_name)
    gemfile = File.open(File.join(project_path, 'Gemfile'), 'a')

    File.foreach(gemfile).any? do |line|
      line.match(/#{Regexp.quote(gem_name)}/)
    end
  end
end

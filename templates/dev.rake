namespace :dev do
  desc "Set up the development environment"
  task prime: ["db:reset", "dev:db:seed"]

  namespace :db do
    desc "Seed the development database"
    task seed: :environment do |t, args|
      DevelopmentSoil.seed(*args.extras)
    end
  end
end

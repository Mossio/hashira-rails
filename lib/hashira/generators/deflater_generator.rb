require "hashira/rails/generator_base"

module Hashira
  class DeflaterGenerator < Hashira::Rails::GeneratorBase
    def add_gem
      updating_gemfile do |gemfile|
        gemfile.add_gem "heroku-deflater",
          git: "https://github.com/romanbsd/heroku-deflater.git",
          group: :production
        gemfile.organize
      end

      run_bundle_install
    end
  end
end

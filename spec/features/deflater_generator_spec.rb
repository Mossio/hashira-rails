require "spec_helper"

RSpec.describe "The deflater generator", type: :feature do
  before(:all) do
    run_hashira_generator(:deflater)
  end

  it "adds the heroku-deflater gem to the Gemfile" do
    expect(gemfile).to list_gem(
      "heroku-deflater",
      git: "https://github.com/romanbsd/heroku-deflater.git",
      group: :production,
    )
  end
end

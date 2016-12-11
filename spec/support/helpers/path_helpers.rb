module Hashira::Test
  def self.project_directory
    Pathname.new("../../../../").expand_path(__FILE__)
  end
end

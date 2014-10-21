Dir[File.dirname(__FILE__) + "/../lib/**/*.rb"].each { |f| require f }

IS_RAKE_TASK = (!! ($0 =~ /rake/))

if IS_RAKE_TASK
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "db"
    add_filter "test"
    add_filter "config"
  end
end

require "minitest/autorun"
require "minitest/pride"

Dir[File.join("./test/support/**/*.rb")].sort.each { |f| require f }

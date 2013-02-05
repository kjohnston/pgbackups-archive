Dir[File.dirname(__FILE__) + "/../lib/**/*.rb"].each { |f| require f }

if RUBY_ENGINE == "ruby"
  begin
    require "simplecov"
    SimpleCov.start do
      add_filter "test"
      add_filter "config"
      command_name "MiniTest"
    end
  rescue LoadError
    warn "unable to load SimpleCov"
  end
end

require "thincloud/test"



# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join("./test/support/**/*.rb")].sort.each { |f| require f }

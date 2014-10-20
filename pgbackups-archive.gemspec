$:.push File.expand_path("../lib", __FILE__)

require "pgbackups-archive/version"

Gem::Specification.new do |s|
  s.name        = "pgbackups-archive"
  s.version     = PgbackupsArchive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kenny Johnston"]
  s.email       = ["kjohnston.ca@gmail.com"]
  s.homepage    = "http://github.com/kjohnston/pgbackups-archive"
  s.summary     = %q{A means of automating Heroku's pgbackups and archiving them to Amazon S3 via the fog gem.}
  s.description = %q{A means of automating Heroku's pgbackups and archiving them to Amazon S3 via the fog gem.}
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "bundler", ">= 1.2.3"
  s.add_dependency "fog",     ">= 1.4.0"
  s.add_dependency "heroku",  ">= 2.34.0"
  s.add_dependency "rake",    ">= 0.9.2.2"

  s.add_development_dependency "guard-minitest", "~> 2.3.2"
  s.add_development_dependency "minitest-rails", "~> 2.1.0"
  s.add_development_dependency "mocha",          "~> 1.1.0"
  s.add_development_dependency "simplecov",      "~> 0.9.1"
end

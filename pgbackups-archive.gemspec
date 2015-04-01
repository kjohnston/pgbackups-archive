$:.push File.expand_path("../lib", __FILE__)

require "pgbackups-archive/version"

Gem::Specification.new do |s|
  s.name        = "pgbackups-archive"
  s.version     = PgbackupsArchive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kenny Johnston"]
  s.email       = ["kjohnston.ca@gmail.com"]
  s.homepage    = "http://github.com/kjohnston/pgbackups-archive"
  s.summary     = %q{Automates archival of Heroku PGBackups to S3}
  s.description = %q{A means of automating Heroku PGBackups and archiving them to Amazon S3.}
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  # Heroku PGBackups launched when 3.28.6 shipped (replacing older PG Backups)
  s.add_runtime_dependency "heroku", ">= 3.28.6"

  s.add_runtime_dependency "fog-aws"
  s.add_runtime_dependency "rake"

  s.add_development_dependency "bundler"
  s.add_development_dependency "guard",          "~> 2.12", "~> 2.12.5"
  s.add_development_dependency "guard-minitest", "~> 2.3",  ">= 2.3.2"
  s.add_development_dependency "minitest-rails", "~> 2.1",  ">= 2.1.0"
  s.add_development_dependency "mocha",          "~> 1.1",  ">= 1.1.0"
  s.add_development_dependency "simplecov",      "~> 0.9",  ">= 0.9.1"
end

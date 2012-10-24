# -*- encoding: utf-8 -*-
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

  s.add_dependency "bundler", "~> 1.2.1"
  s.add_dependency "fog",    ">= 1.4.0"
  s.add_dependency "heroku", "~> 2.32.14"
  s.add_dependency "rake",   ">= 0.9.2.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

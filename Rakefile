#!/usr/bin/env rake

require "bundler/gem_tasks"

load "tasks/pgbackups_archive.rake"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

task default: :test

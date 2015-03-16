namespace :pgbackups do

  desc "Capture a Heroku PGBackups backup and archive it to Amazon S3."
  task :archive do
    PgbackupsArchive::Job.call
  end

end

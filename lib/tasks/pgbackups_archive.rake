namespace :pgbackups do

  desc "Perform a pgbackups backup then archive to S3."
  task :archive do
    Heroku::Client::PgbackupsArchive.perform
  end

end

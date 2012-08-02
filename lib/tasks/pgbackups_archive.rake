namespace :pgbackups do

  task :archive do
    archive = Heroku::Client::PgbackupsArchive.new(:pgbackups_url => ENV["PGBACKUPS_URL"])
    archive.capture
    archive.store
  end

end

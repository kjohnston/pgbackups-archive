
namespace :pgbackups do

  desc "Capture a Heroku PGBackups backup and archive it to Amazon S3."

  task :archive, [:app, :database] do |t, args|

    args.with_defaults(app: ENV['PGBACKUPS_APP'])
    args.with_defaults(database: ENV['PGBACKUPS_DATABASE'])

    PgbackupsArchive::Job.new(:app => args.app, :database => args.database).call
  end

end

if defined?(Rails)
  module PgbackupsArchive
    class Railtie < Rails::Railtie
      railtie_name :pgbackups_archive

      rake_tasks do
        load "tasks/pgbackups_archive.rake"
      end
    end
  end
end

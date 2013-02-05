if defined?(Rails)
  if Rails.version < "3"
    load "tasks/pgbackups_archive.rake"
  else
    module PgbackupsArchive
      class Railtie < Rails::Railtie
        rake_tasks do
          load "tasks/pgbackups_archive.rake"
        end
      end
    end
  end
end

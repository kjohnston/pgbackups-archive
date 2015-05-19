require "heroku/command/pg"
require "heroku/command/pg_backups"
require "heroku/api"
require "tmpdir"

class PgbackupsArchive::Job

  attr_reader :client
  attr_accessor :backup_url, :created_at

  def self.call
    new.call
  end

  def initialize(attrs={})
    @app = attrs.fetch(:app, ENV['PGBACKUPS_APP'])
    @database = attrs.fetch(:database, ENV['PGBACKUPS_DATABASE'] || 'DATABASE_URL')
    Heroku::Command.load
    @client = Heroku::Command::Pg.new([], :app => @app)
  end

  def call
    # expire  # Disabled b/c Heroku seems to be keeping only 2 on its own
    capture
    download
    archive
    delete
  end

  def archive
    if PgbackupsArchive::Storage.new(key, file).store
      client.display "Backup archived"
    end
  end

  def capture
    attachment = client.send(:generate_resolver).resolve(@database)
    backup = client.send(:hpg_client, attachment).backups_capture
    client.send(:poll_transfer, "backup", backup[:uuid])

    self.created_at = backup[:created_at]

    self.backup_url = Heroku::Client::HerokuPostgresqlApp
      .new(@app).transfers_public_url(backup[:num])[:url]
  end

  def delete
    File.delete(temp_file)
  end

  def download
    File.open(temp_file, "wb") do |output|
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        output.write chunk
      end

      # https://github.com/excon/excon/issues/475
      Excon.get backup_url,
        :response_block    => streamer,
        :omit_default_port => true
    end
  end

  def expire
    transfers = client.send(:hpg_app_client, @app).transfers
      .select  { |b| b[:from_type] == "pg_dump" && b[:to_type] == "gof3r" }
      .sort_by { |b| b[:created_at] }

    if transfers.size > pgbackups_to_keep
      backup_id  = "b%03d" % transfers.first[:num]
      backup_num = client.send(:backup_num, backup_id)

      expire_backup(backup_num)

      client.display "Backup #{backup_id} expired"
    end
  end

  private

  def expire_backup(backup_num)
    client.send(:hpg_app_client, @app)
      .transfers_delete(backup_num)
  end

  def environment
    defined?(Rails) ? Rails.env : nil
  end

  def file
    File.open(temp_file, "r")
  end

  def key
    timestamp = created_at.gsub(/\/|\:|\.|\s/, "-").gsub(/\+/, '').concat(".dump")
    ["pgbackups", @app, environment, timestamp].compact.join("/")
  end

  def pgbackups_to_keep
     ENV["PGBACKUPS_KEEP"] ? ENV["PGBACKUPS_KEEP"].to_i : 30
  end

  def temp_file
    "#{Dir.tmpdir}/pgbackup"
  end

end

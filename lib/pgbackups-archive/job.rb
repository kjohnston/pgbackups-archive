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
    Heroku::Command.load
    @client = Heroku::Command::Pg.new([], :app => ENV["PGBACKUPS_APP"])
  end

  def call
    capture
    download
    archive
    delete
  end

  def archive
    PgbackupsArchive::Storage.new(key, file).store
  end

  def capture
    attachment = client.send(:generate_resolver).resolve(database)
    backup = client.send(:hpg_client, attachment).backups_capture
    client.send(:poll_transfer, "backup", backup[:uuid])

    self.created_at = backup[:created_at]

    self.backup_url = Heroku::Client::HerokuPostgresqlApp
      .new(ENV["PGBACKUPS_APP"]).transfers_public_url(backup[:num])[:url]
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

  private

  def database
    ENV["PGBACKUPS_DATABASE"] || "DATABASE_URL"
  end

  def environment
    defined?(Rails) ? Rails.env : nil
  end

  def file
    File.open(temp_file, "r")
  end

  def key
    timestamp = created_at.gsub(/\/|\:|\.|\s/, "-").concat(".dump")
    ["pgbackups", environment, timestamp].compact.join("/")
  end

  def temp_file
    "#{Dir.tmpdir}/pgbackup"
  end

end

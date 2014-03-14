require "heroku/client"
require "tmpdir"

class Heroku::Client::PgbackupsArchive

  attr_reader :client, :pgbackup

  def self.perform
    self.database_url.split(',').map(&:strip).each do |db_url|
      backup = new
      backup.capture(db_url)
      backup.download
      backup.archive
      backup.delete
    end
  end

  def initialize(attrs={})
    Heroku::Command.load
    @client   = Heroku::Client::Pgbackups.new pgbackups_url
    @pgbackup = nil
  end

  def archive
    PgbackupsArchive::Storage.new(key, file).store
  end

  def capture(db_url=nil)
    @pgbackup = @client.create_transfer(db_url, db_url, nil,
      "BACKUP", :expire => true)

    until @pgbackup["finished_at"]
      print "."
      sleep 1
      @pgbackup = @client.get_transfer @pgbackup["id"]
    end
  end

  def delete
    File.delete temp_file
  end

  def download
    File.open(temp_file, "wb") do |output|
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        output.write chunk
      end
      Excon.get(@pgbackup["public_url"], :response_block => streamer)
    end
  end

  private

  def self.database_url
    ENV["PGBACKUPS_DATABASE_URL"] || ENV["DATABASE_URL"]
  end

  def environment
    defined?(Rails) ? Rails.env : nil
  end

  def file
    File.open temp_file, "r"
  end

  def key
    folder_name = ENV["PGBACKUPS_FOLDER"] || URI(@pgbackup['public_url']).path.split('/').last || "pgbackups"
    [folder_name, environment, @pgbackup["finished_at"]
      .gsub(/\/|\:|\.|\s/, "-").concat(".dump")].compact.join("/")
  end

  def pgbackups_url
    ENV["PGBACKUPS_URL"]
  end

  def temp_file
    "#{Dir.tmpdir}/#{URI(@pgbackup['public_url']).path.split('/').last}"
  end

end

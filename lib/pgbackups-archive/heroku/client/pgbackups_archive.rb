require "heroku/client"

class Heroku::Client::PgbackupsArchive

  attr_reader :client, :backup

  def initialize(attrs={})
    Heroku::Command.load
    @client = Heroku::Client::Pgbackups.new attrs[:pgbackups_url]
    @backup = nil
    @environment = attrs[:env] || (defined?(Rails) ? Rails.env : nil)
  end

  def capture
    @backup = @client.create_transfer ENV["DATABASE_URL"], ENV["DATABASE_URL"], nil, "BACKUP", :expire => true

    until @backup["finished_at"]
      print "."
      sleep 1
      @backup = @client.get_transfer @backup["id"]
    end

    @backup
  end

  def file
    open @backup["public_url"]
  end

  def key
    ["pgbackups", @environment, @backup["finished_at"].gsub(/\/|\:|\.|\s/, "-").concat(".dump")].join("/")
  end

  def store
    PgbackupsArchive::Storage.new(key, file).store
  end

end

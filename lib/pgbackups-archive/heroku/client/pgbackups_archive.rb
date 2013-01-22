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
    @backup = @client.create_transfer database_url, database_url, nil, "BACKUP", :expire => true

    until @backup["finished_at"]
      print "."
      sleep 1
      @backup = @client.get_transfer @backup["id"]
    end

    @backup
  end

  def database_url
    ENV["PGBACKUPS_DATABASE_URL"] || ENV["DATABASE_URL"]
  end


  def file 
    File.open(temp_file_path, 'wb') do |output|
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        puts "Download backup : #{(remaining_bytes.to_f / total_bytes) * 100}%"  
        output.write chunk
      end
      Excon.get(@backup["public_url"], :response_block => streamer)
    end
    File.open temp_file_path, 'r'
  end

  def temp_file_path
    "./tmp/#{URI(@backup["public_url"]).path.split('/').last}"
  end

  def key
    ["pgbackups", @environment, @backup["finished_at"].gsub(/\/|\:|\.|\s/, "-").concat(".dump")].join("/")
  end

  def store
    PgbackupsArchive::Storage.new(key, file).store
  end

end

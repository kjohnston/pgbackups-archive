require "fog/aws"
require "open-uri"

class PgbackupsArchive::Storage

  def initialize(key, file)
    @key = key
    @file = file
  end

  def connection
    Fog::Storage.new({
      :provider              => "AWS",
      :aws_access_key_id     => ENV["PGBACKUPS_AWS_ACCESS_KEY_ID"],
      :aws_secret_access_key => ENV["PGBACKUPS_AWS_SECRET_ACCESS_KEY"],
      :region                => ENV["PGBACKUPS_REGION"],
      :persistent            => false
    })
  end

  def bucket
    directory = connection.directories.get ENV["PGBACKUPS_BUCKET"]
    directory = connection.directories.create(
        :key => ENV["PGBACKUPS_BUCKET"],
        :public => false
    ) if directory.nil?
    directory
  end

  def store
    bucket.files.create :key => @key, :body => @file, :public => false, :encryption => "AES256"
  end

end

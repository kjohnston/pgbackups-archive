require "minitest_helper"
require "heroku/client"

describe Heroku::Client::PgbackupsArchive do
  let(:archive) {
    Heroku::Client::PgbackupsArchive.new(
      :pgbackups_url => "https://ip:password@pgbackups.heroku.com/client"
    )
  }
  let(:backup) { { "finished_at" => "some timestamp" } }

  it "should use a pgbackup client" do
    archive.client.class.must_equal Heroku::Client::Pgbackups
  end

  describe "given a finished_at timestamp" do
    before { archive.client.stubs(:create_transfer).returns(backup) }

    it "should capture the backup" do
      archive.capture.must_equal backup
    end

    it "should store the backup" do
      archive.stubs(:key).returns("key")
      archive.stubs(:file).returns("file")
      archive.store.class.must_equal Fog::Storage::AWS::File
    end
  end

  describe '#file' do
    before do

      archive.instance_eval do
        @backup = {}
        @backup['public_url'] = "https://raw.github.com/kjohnston/pgbackups-archive/master/pgbackups-archive.gemspec"
      end

    end

    it 'downloads the backup file' do
      archive.file.read.must_be :=~, /Gem::Specification/
    end

  end

  describe "configure the backup database" do

    describe "backup database is not configured" do
      before do
        ENV["PGBACKUPS_DATABASE_URL"] = nil
        ENV["DATABASE_URL"] = "db_url"
      end

      it "defaults to using the DATABASE_URL" do
        archive.client.expects(:create_transfer)
        .with("db_url", "db_url", nil, "BACKUP", :expire => true)
        .returns(backup)

        archive.capture
      end
    end

    describe "backup database is configured" do
      before do
        ENV["PGBACKUPS_DATABASE_URL"] = "backup_db"
        ENV["DATABASE_URL"] = "db_url"
      end

      it "defaults to using the DATABASE_URL" do
        archive.client.expects(:create_transfer)
        .with("backup_db", "backup_db", nil, "BACKUP", :expire => true)
        .returns(backup)

        archive.capture
      end
    end

  end

end

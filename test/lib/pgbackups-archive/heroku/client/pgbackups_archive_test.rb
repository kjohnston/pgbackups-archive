require "minitest_helper"
require "heroku/client"

describe Heroku::Client::PgbackupsArchive do

  describe "#self.perform" do
    before do
      Heroku::Client::PgbackupsArchive.expects(:new).returns(
        mock(
          :capture  => stub,
          :download => stub,
          :archive  => stub,
          :delete   => stub
        )
      )
    end

    it { Heroku::Client::PgbackupsArchive.perform }
  end

  describe "An instance" do
    let(:backup)   { Heroku::Client::PgbackupsArchive.new }
    let(:pgbackup) { { "finished_at" => "some timestamp" } }

    before do
      ENV["PGBACKUPS_URL"] = "https://ip:password@pgbackups.heroku.com/client"
    end

    it "should use a pgbackup client" do
      backup.client.class.must_equal Heroku::Client::Pgbackups
    end

    describe "given a finished_at timestamp" do
      before { backup.client.stubs(:create_transfer).returns(pgbackup) }

      it "should capture the backup" do
        backup.capture
        backup.pgbackup.must_equal pgbackup
      end

      it "should store the backup" do
        backup.stubs(:key).returns("key")
        backup.stubs(:file).returns("file")
        backup.archive.class.must_equal Fog::Storage::AWS::File
      end
    end

    describe "#file" do
      before do
        backup.instance_eval do
          @pgbackup = {}
          @pgbackup["public_url"] = "https://raw.github.com/kjohnston/pgbackups-archive/master/pgbackups-archive.gemspec"
        end
      end

      it "downloads the backup file" do
        backup.send(:file).read.must_match /Gem::Specification/
      end
    end

    describe "configure the backup database" do
      describe "backup database is not configured" do
        before do
          ENV["PGBACKUPS_DATABASE_URL"] = nil
          ENV["DATABASE_URL"] = "db_url"
        end

        it "defaults to using the DATABASE_URL" do
          backup.client.expects(:create_transfer)
            .with("db_url", "db_url", nil, "BACKUP", :expire => true)
            .returns(pgbackup)

          backup.capture
        end
      end

      describe "backup database is configured" do
        before do
          ENV["PGBACKUPS_DATABASE_URL"] = "backup_db"
          ENV["DATABASE_URL"] = "db_url"
        end

        it "defaults to using the DATABASE_URL" do
          backup.client.expects(:create_transfer)
            .with("backup_db", "backup_db", nil, "BACKUP", :expire => true)
            .returns(pgbackup)

          backup.capture
        end
      end
    end

  end

end

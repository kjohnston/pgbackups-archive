require "test_helper"

describe PgbackupsArchive::Job do

  describe ".call" do
    it { PgbackupsArchive::Job.must_respond_to(:call) }
  end

  describe "instance methods" do
    before do
      @app = "foobar"
      ENV["PGBACKUPS_APP"] = @app
      @job = PgbackupsArchive::Job.new
      @client = @job.client
      @backup_url = "https://raw.githubusercontent.com/kjohnston/pgbackups-archive/master/pgbackups-archive.gemspec"
      @created_at = Time.now
    end

    describe "#initialize" do
      it do
        @client.must_be_kind_of(Heroku::Command::Pg)
        @client.options[:app].must_equal @app
      end
    end

    describe "#call" do
      before do
        @job.expects(:expire)
        @job.expects(:capture)
        @job.expects(:download)
        @job.expects(:archive)
        @job.expects(:delete)
      end

      it { @job.call }
    end

    describe "#archive" do
      before do
        @key  = "some-key"
        @file = "some-file"
        @job.stubs(:key).returns(@key)
        @job.stubs(:file).returns(@file)

        PgbackupsArchive::Storage.expects(:new).with(@key, @file)
          .returns(mock(store: true))

        @client.expects(:display)
      end

      it { @job.archive }
    end

    describe "#capture" do
      before do
        @client.stubs(:generate_resolver).returns(mock(:resolve))
        @client.stubs(:hpg_client)
          .returns(
            mock(backups_capture: {
              uuid:      "baz",
              num:       "10",
              created_at: @created_at }
            )
          )
        @client.stubs(:poll_transfer)

        Heroku::Client::HerokuPostgresqlApp.expects(:new).with(@app)
          .returns(mock(transfers_public_url: { url: @backup_url }))
      end

      it do
        @job.capture
        @job.created_at.must_equal @created_at
        @job.backup_url.must_equal @backup_url
      end
    end

    describe "#delete" do
      it do
        @temp_file = @job.send(:temp_file)
        File.write(@temp_file, "content")
        File.exist?(@temp_file).must_equal true
        @job.delete
        File.exist?(@temp_file).must_equal false
      end
    end

    describe "#download" do
      before { @job.backup_url = @backup_url }

      it do
        @job.download
        @job.send(:file).read.must_match /Gem::Specification/
      end
    end

    describe "#expire" do
      before do
        @transfers = [
          { from_type: "pg_dump", to_type: "gof3r", created_at: Date.today, num: 20 },
          { from_type: "pg_dump", to_type: "gof3r", created_at: Date.today-2, num: 17 },
          { from_type: "pg_dump", to_type: "gof3r", created_at: Date.today-1, num: 18 },
          { from_type: "pg_dump", to_type: "foo", created_at: Date.today-1, num: 19 }
        ]

        @client.expects(:hpg_app_client).with(@app).returns(mock(transfers: @transfers))
      end

      describe "when slots are available" do
        it "does not expire a backup" do
          @job.expire
        end
      end

      describe "when a slot needs to be freed" do
        before do
          ENV["PGBACKUPS_KEEP"] = "2"
          @client.expects(:backup_num).with("b017").returns("017")
          @job.expects(:expire_backup).with("017")
          @client.expects(:display)
        end

        it "expires a backup" do
          @job.expire
        end
      end
    end

  end

end

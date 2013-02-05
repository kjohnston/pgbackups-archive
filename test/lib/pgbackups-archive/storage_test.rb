require "minitest_helper"

describe PgbackupsArchive::Storage do
  let(:connection) {
    Fog::Storage.new(
      :provider              => "AWS",
      :aws_access_key_id     => "XXX",
      :aws_secret_access_key => "YYY")
  }
  let(:bucket)     { connection.directories.create(:key => "someapp-backups") }
  let(:key)        { "pgbackups/test/2012-08-02-12-00-00.dump" }
  let(:file)       { "test" }
  let(:storage)    { PgbackupsArchive::Storage.new(key, file) }

  before do
    Fog.mock!
    storage.stubs(:connection).returns(connection)
    storage.stubs(:bucket).returns(bucket)
  end

  it "should create a fog connection" do
    storage.connection.class.must_equal Fog::Storage::AWS::Mock
  end

  it "should create a fog directory" do
    storage.bucket.class.must_equal Fog::Storage::AWS::Directory
  end

  it "should create a fog file" do
    storage.store.class.must_equal Fog::Storage::AWS::File
  end

end

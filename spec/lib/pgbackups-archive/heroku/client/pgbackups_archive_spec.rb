require "spec_helper"
require "heroku/client"

describe Heroku::Client::PgbackupsArchive do
  let(:archive) { Heroku::Client::PgbackupsArchive.new(:pgbackups_url => "https://ip:password@pgbackups.heroku.com/client") }
  let(:backup) { { "finished_at" => "some timestamp" } }

  it "should use a pgbackup client" do
    archive.client.class.should eq Heroku::Client::Pgbackups
  end

  context "given a finished_at timestamp" do
    before { archive.client.stub(:create_transfer).and_return(backup) }

    it "should capture the backup" do
      archive.capture.should eq backup
    end

    it "should store the backup" do
      archive.stub(:key).and_return("key")
      archive.stub(:file).and_return("file")
      archive.store.class.should eq Fog::Storage::AWS::File
    end
  end

  context 'configure the backup database' do

    context 'backup database is not configured' do
      before do 
        ENV['PGBACKUPS_DATABASE'] = nil
        ENV['DATABASE_URL'] = 'db_url'
      end

      it 'defaults to using the DATABASE_URL' do
        archive.client.should_receive(:create_transfer).with('db_url', 'db_url', nil, 'BACKUP', :expire => true).and_return(backup)
        archive.capture
      end
    end

    context 'backup database is configured' do
      before do 
        ENV['PGBACKUPS_DATABASE'] = 'PURPLE'
        ENV['PURPLE'] = 'db_purple_url'
      end

      it 'defaults to using the DATABASE_URL' do
        archive.client.should_receive(:create_transfer).with('db_purple_url', 'db_purple_url', nil, 'BACKUP', :expire => true).and_return(backup)
        archive.capture
      end
    end



  end
  

end

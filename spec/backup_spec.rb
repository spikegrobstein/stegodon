require File.dirname(__FILE__) + '/spec_helper'

describe Stegodon::Backup do

  include FakeFS::SpecHelpers

  let(:backup_name) { 'hourly' }
  let(:backup) { Stegodon::Backup.new( backup_name ) }

  before do
    Stegodon::Backup.any_instance.stub(:backup! => true)
    Cocaine::CommandLine.any_instance.stub(:run => true)
  end

  context "initializing" do


    it "should set default pg_dump_bin" do
      backup.pg_dump_bin.should == Stegodon::Backup::PG_DUMP
    end

    it "should set the backup name" do
      backup.backup_name.should == backup_name
    end

    it "should call backup!" do
      Stegodon::Backup.any_instance.should_receive(:backup!)
      b = Stegodon::Backup.new('new')
    end

  end

  context "when overriding configuration" do

    it "should fetch the configuration" do
      Stegodon::Configuration.should_receive(:get).with(:default)

      Stegodon::Backup.new(:hourly) do
        configuration :default
      end
    end

  end

  context "#current_backup_path" do

    it "should use the #backup_location" do
      backup.should_receive(:backup_location)
      backup.backup_location
    end

  end

  context "#cleanup_old" do

    it "should remove the .old" do
      FakeFS do
        File.open(backup.current_backup_path, 'w').write('new_backup')
        File.open(backup.old_backup_path, 'w').write('old_backup')

        backup.cleanup_old

        File.exists?(backup.current_backup_path).should be_false
        File.exists?(backup.old_backup_path).should be_true
      end
    end

    it "should rename the old one to .old" do
      FakeFS do
        File.open(backup.current_backup_path, 'w').write('new_backup')
        File.open(backup.old_backup_path, 'w').write('old_backup')

        backup.cleanup_old

        File.open(backup.old_backup_path, 'r').read.should == 'new_backup'
      end
    end

  end

  context "#backup_database" do

    context "when calling the command via cocaine" do

      def cocaine_should_contain(arg, state=true)
        Cocaine::CommandLine.should_receive(:new) do |a|
          (!!arg[1].match(/\b#{arg}\b/)).should == state
        end.and_call_original
      end

      it "should include -v if verbose is set to true" do

        cocaine_should_contain '-v'

        Stegodon::Backup.new(:test) do
          verbose true
        end.backup_database

      end

      it "should not include -v if verbose is set to false" do
        cocaine_should_contain '-v', false

        Stegodon::Backup.new(:test) do
          verbose false
        end.backup_database
      end

      it "should include :encoding if @encoding is set" do
        cocaine_should_contain ':encoding'

        Stegodon::Backup.new(:test) do
          encoding 'SQL_ASCII'
        end.backup_database
      end

      it "should include :db_user if @configuration.username is used" do
        cocaine_should_contain ':db_user'

        Stegodon::Configuration.new(:default) do
          username 'spike'
        end

        Stegodon::Backup.new(:test) do
          configuration :default
        end.backup_database
      end

      it "should include --no-unlogged-table-data if no_unlogged_table_data is set" do
        cocaine_should_contain '--no-unlogged-table-data'

        Stegodon::Backup.new(:test) do
          no_unlogged_table_data true
        end.backup_database
      end

    end
  end

  context "#backup!" do

    it "should call #cleanup_old"

    it "should call #backup_database"

  end
end

require 'cocaine'
require 'fileutils'

module Stegodon
  class Backup < Base
    PG_DUMP = 'pg_dump'
    PG_DUMPALL = 'pg_dumpall'

    dsl_accessor :configuration,
      :database,
      :encoding,
      :location,
      :no_unlogged_table_data,
      :verbose,
      :pg_dump_bin,
      :pg_dumpall_bin

    attr_accessor :backup_name

    def initialize(backup_name, &block)
      @backup_name = backup_name

      @pg_dump_bin = PG_DUMP
      @pg_dumpall_bin = PG_DUMPALL

      run_dsl &block
      self.backup!
    end

    def configuration=(name)
      puts "fetching configuration: #{ name }"
      @configuration = Configuration.get(name)

      ap @configuration
    end

    # path to the directory to put backups
    def backup_location
      @location
    end

    def current_backup_path
      File.join( self.backup_location, "#{ @database }-#{ @backup_name }" )
    end

    def old_backup_path
      "#{ current_backup_path }.old"
    end

    def current_global_backup_path
      "#{ self.current_backup_path }-globals"
    end

    def old_global_backup_path
      "#{ current_global_backup_path }.old"
    end

    def cleanup_old_backups
      File.exists?(old_backup_path)             && File.unlink(old_backup_path)
      File.exists?(current_backup_path)         && FileUtils.mv(current_backup_path, old_backup_path)

      File.exists?(old_global_backup_path)      && File.unlink(old_global_backup_path)
      File.exists?(current_global_backup_path)  && FileUtils.mv(current_global_backup_path, old_global_backup_path)
    end

    def backup_globals
      line = Cocaine::CommandLine.new( @pg_dumpall_bin,
                                       '-g -v -f :dump_file',
                                       :dump_file => current_global_backup_path )
      line.run
    end

    def backup_database
      opts = []
      opts << '-v' if @verbose
      opts << '-E :encoding' if @encoding
      opts << '--no-unlogged-table-data' if @no_unlogged_table_data
      opts << '-U :db_user' if @configuration.username
      opts << '-Fc'
      opts << '-f :dump_file' if @location
      opts << ':database'

      line = Cocaine::CommandLine.new( @pg_dump_bin,
                                      opts.join(' '),
                                      :encoding => @encoding,
                                      :db_user => @configuration.username,
                                      :dump_file => current_backup_path,
                                      :database => @database )
      puts line.command

      line.run
    end

    def backup!
      cleanup_old_backups
      # backup_globals
      backup_database
    end

  end
end

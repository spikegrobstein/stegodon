module Stegodon
  class Backup < Base
    PG_DUMP = '/usr/bin/pg_dump'
    PG_DUMPALL = '/usr/bin/pg_dumpall'

    dsl_accessor :configuration,
      :database,
      :location

    def initialize(&block)
      run_dsl &block
    end

    # path to the directory to put backups
    def backup_location
      @location
    end

    def current_backup_path
      File.join( self.backup_location, "#{ @db_name }-#{ @backup_type }" )
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
      line = Cocaine::CommandLine.new( PG_DUMPALL,
                                       '-g -v -f :dump_file',
                                       :dump_file => current_global_backup_path )
      line.run
    end

    def backup_table
      line = Cocaine::CommandLine.new( PG_DUMP,
                                      '-v -E :encoding --no-unlogged-table-data -U :db_user -Fc -f :dump_file :db_name',
                                      :encoding => @encoding,
                                      :db_user => @db_user,
                                      :dump_file => current_backup_path,
                                      :db_name => @db_name )
      line.run
    end

    def backup!
      cleanup_old_backups
      backup_globals
      backup_table
    end

    def run!

    end

  end
end

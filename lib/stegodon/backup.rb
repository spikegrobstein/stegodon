require 'benzo'
require 'fileutils'

module Stegodon
  class Backup < Base
    PG_DUMP = 'pg_dump'

    dsl_accessor :configuration,
      :database,
      :encoding,
      :location,
      :no_unlogged_table_data,
      :verbose,
      :pg_dump_bin

    attr_accessor :backup_name

    def initialize(backup_name, &block)
      @backup_name = backup_name
      @pg_dump_bin = PG_DUMP

      @location = './'

      super

      unless @configuration
        @configuration = Stegodon::Configuration.new
      end

      self.backup!
    end

    def configuration=(name)
      @configuration = Configuration.get(name)
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

    def cleanup_old
      File.exists?(old_backup_path)             && File.unlink(old_backup_path)
      File.exists?(current_backup_path)         && FileUtils.mv(current_backup_path, old_backup_path)
    end

    def backup_database
      line = Benzo.line( @pg_dump_bin,
                       '-v'                       => @verbose,
                       '-E :encoding'             => @encoding,
                       '--no-unlogged-table-data' => @no_unlogged_table_data,
                       '-U :db_user'              => @configuration.username,
                       '-Fc'                      => true,
                       '-f :dump_file'            => current_backup_path,
                       ':database'                => @database
                       )

      line.run
    end

    def backup!
      cleanup_old
      backup_database
    end

  end
end

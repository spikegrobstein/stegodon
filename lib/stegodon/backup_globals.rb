module Stegodon
  class BackupGlobals < Base

    PG_DUMPALL = 'pg_dumpall'

    dsl_accessor :configuration,
      :verbose,
      :location,
      :pg_dumpall_bin

    attr_accessor :backup_name

    def initialize(backup_name, &block)
      @backup_name = backup_name
      @pg_dumpall_bin = PG_DUMPALL
      @location = './'

      super

      self.backup!
    end

    def configuration=(name)
      @configuration = Configuration.get(name)
    end

    def backup_globals
      line = Benzo.line( @pg_dumpall_bin,
                       '-g' => true,
                       '-v' => true,
                       '-f :dump_file' => current_global_backup_path
                       )

      line.run
    end

    # path to the directory to put backups
    def backup_location
      @location
    end

    def current_global_backup_path
      File.join( self.backup_location, "globals-#{ @backup_name }" )
    end

    def old_global_backup_path
      "#{ current_global_backup_path }.old"
    end

    def cleanup_old
      File.exists?(old_global_backup_path)      && File.unlink(old_global_backup_path)
      File.exists?(current_global_backup_path)  && FileUtils.mv(current_global_backup_path, old_global_backup_path)
    end

    def backup!
      cleanup_old
      backup_globals
    end

  end
end

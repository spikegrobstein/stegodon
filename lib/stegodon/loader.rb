module Stegodon
  class Loader < Base

    PG_RESTORE = 'pg_restore'
    PSQL = 'psql'
    CREATEDB = 'createdb'
    DROPDB = 'dropdb'

    dsl_accessor :configuration,
      :database,
      :encoding,
      :owner,
      :template,
      :globals_path,
      :dump_path,
      :verbose,
      :pg_restore_bin,
      :psql_bin,
      :createdb_bin,
      :dropdb_bin

    def initialize(*args, &block)
      @pg_restore_bin = PG_RESTORE
      @psql_bin = PSQL
      @createdb_bin = CREATEDB
      @dropdb_bin = DROPDB

      @template = 'template0'

      super

      unless @configuration
        @configuration = Stegodon::Configuration.new
      end

      self.load!
    end

    def load_globals
      line = Benzo.line( @psql_bin,
                      '-f :globalfile' => @globals_path
                    )

      line.run
    end

    def drop_database
      line = Benzo.line( @dropdb_bin,
                       ':db_name' => @database,
                       :expected_outcodes => [ 0, 1 ]
                       )

      line.run
    end

    def create_database
      line = Benzo.line( @createdb_bin,
                       '-E :encoding' => @encoding,
                       '-O :owner' => @owner,
                       '-T :template' => @template,
                       ':db_name' => @database
                       )

      line.run
    end

    def load_into_postgres
      line = Benzo.line( @pg_restore_bin,
                       '-v' => @verbose,
                       # '-c' => true,
                       '-d :database_name' => @database,
                       ':dump_path' => @dump_path
                       )

      line.run
    end

    def load!
      drop_database
      load_globals
      create_database
      load_into_postgres
    end

  end
end
module Adapters
  class Pg
    def initialize(config)
      @config = config
      @conn = init_connection
    end

    def get_all_tables_names
      sql = %[
        SELECT table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
        AND table_schema = 'public'
        AND table_catalog = '#{@config[:database]}';
      ]
      @conn.exec(sql).to_a
    end

    def get_table_data(table_name)
      sql = "SELECT * FROM #{table_name}"
      @conn.exec(sql).to_a
    end

    def get_primary_key(table_name)
      sql = %[
        SELECT k.column_name
        FROM information_schema.table_constraints t
        JOIN information_schema.key_column_usage k
        USING(constraint_name,table_schema,table_name)
        WHERE t.constraint_type='PRIMARY KEY'
        AND t.table_schema='public'
        AND t.table_name='#{table_name}'
        AND t.table_catalog = '#{@config[:database]}';
      ]
      @conn.exec(sql).to_a
    end

    private

    def init_connection
      PG::Connection.new(map_to_db_config)
    end

    def map_to_db_config
      {
        dbname: @config[:database],
        host: @config[:host],
        user: @config[:username],
        password: @config[:password],
        port: @config[:port]
      }.compact
    end
  end
end

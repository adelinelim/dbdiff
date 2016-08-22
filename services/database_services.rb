module Services
  class Database
    def get_databases(type, database_name)
      conn = initialize_db_conn(type, database_name)
      result = yield(conn)
      result.map do |row|
        row["database_name"]
      end
    end

    private

    def mysql_databases_query
      "SELECT DISTINCT table_schema AS database_name FROM information_schema.tables"
    end

    def pg_databases_query
      "SELECT datname AS database_name FROM pg_database WHERE datistemplate = false"
    end

    def read_db_yaml(type, database)
      configs = YAML::load_file("config/#{type}_database.yml")[database.to_s]
    end

    def initialize_db_conn(db_type, database)
      config = read_db_yaml(db_type, database)
      if config.present?
        if db_type.to_sym == :pg
          PG::Connection.new(config)
        elsif db_type.to_sym == :mysql
          Mysql2::Client.new(config)
        else
          raise "The database type is not support"
        end
      else
        raise "Need to set the database connection in *.yml files"
      end
    end

    def generate_select_tag(list, id)
      options = list.map do |db|
        "<option value='#{db}'>#{db}</option>"
      end

      Components::ComboBox.new(select: {hidden: true, id: id}, option: options)

      option = ""
      list.each do |db|
        option += "<option value='#{db}'>#{db}</option>"
      end
      "<select hidden='true' id='#{id}'>#{option}</select>"
    end
  end

  class GridGenerator
    mysql_db = get_databases(:mysql, :default) do |conn|
      conn.query(mysql_databases_query).to_a
    end

    pg_db = get_databases(:pg, :default) do |conn|
      conn.exec(pg_databases_query).to_a
    end
  end
end

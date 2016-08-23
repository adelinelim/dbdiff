module Adapters
  class Factory
    def initialize(connection_id)
      @connection_id = connection_id
      @connection_config = read_connection_config
    end

    def create
      case @connection_config[:adapter].to_sym
      when :pg
        Pg.new(@connection_config)
      when :mysql
        Mysql.new(@connection_config)
      end
    end

    def read_connection_config
      all_databases_config = File.read("config/databases.json").to_data.deep_symbolize_keys
      all_databases_config[@connection_id.to_sym]
    end
  end
end

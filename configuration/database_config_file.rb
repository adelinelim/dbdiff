module Configuration
  class DatabaseConfigFile
    DATABASE_CONFIG_FILE_PATH = "config/databases.json"

    def initialize(params)
      @params = params
    end

    def write_to_db_config
      id = @params["name"]
      all_dbs_config = DatabaseConfigFile.read

      if all_dbs_config[id].blank?
        all_dbs_config[id] = {}
      end

      @params.each do |k, v|
        if v.present? && k != "name"
          all_dbs_config[id][k] = v
        end
      end

      DatabaseConfigFile.write(all_dbs_config)
    end

    def self.read
      File.read(DATABASE_CONFIG_FILE_PATH).to_data
    end

    def self.write(data)
      File.write(DATABASE_CONFIG_FILE_PATH, data)
    end
  end
end

module Configuration
  class DatabaseFile
    DATABASE_CONFIG_FILE_PATH = "config/databases.json"

    def self.read_database_config_file
      File.read(DATABASE_CONFIG_FILE_PATH).to_data
    end

    def self.write_to_database_config_file(data)
      File.write(DATABASE_CONFIG_FILE_PATH, data)
    end
  end
end

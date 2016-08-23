module Configuration
  class DatabaseConfigFile
    DATABASE_CONFIG_FILE_PATH = "config/databases.json"

    def initialize(id)
      @id = id
    end

    def self.read
      File.read(DATABASE_CONFIG_FILE_PATH).to_data
    end

    def self.write(data)
      File.write(DATABASE_CONFIG_FILE_PATH, data)
    end
  end
end

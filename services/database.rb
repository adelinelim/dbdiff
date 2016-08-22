# class Database
#   def self.read_db_yaml(type, database)
#     configs = YAML::load_file("config/#{type}_database.yml")[database.to_s]
#   end
#
#   def self.initialize_db_conn(db_type, database)
#     config = read_db_yaml(db_type, database)
#     if config.present?
#       if db_type.to_sym == :pg
#         PG::Connection.new(config)
#       elsif db_type.to_sym == :mysql
#         Mysql2::Client.new(config)
#       else
#         raise "The database type is not support"
#       end
#     else
#       raise "Need to set the database connection in *.yml files"
#     end
#   end
# end

require_relative "initializer"
id = "fulcrum local"
adapter = Adapters::Factory.new(id).create
puts adapter
table_names = adapter.get_tables_names
puts table_names

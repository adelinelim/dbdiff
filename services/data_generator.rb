module Services
  class DataGenerator
    FILE_NUMBER_NAME = ".filenumber"

    def initialize(params)
      @params = params
      @adapter = init_adapter
    end

    def generate
      save_all_tables_data_into_json
    end

    private

    def save_all_tables_data_into_json
      tables = get_tables_data
      data = generate_data_json(tables)
      write_data_json(data)
    end

    def init_adapter
      Adapters::Factory.new(@params[:cid]).create
    end

    def get_tables_data
      table_names = @adapter.get_all_tables_names

      tables = {}
      table_names.each do |t|
        table_name = t["table_name"].to_sym
        # retrieve data from table
        tables[table_name] = {}
        tables[table_name][:data] = @adapter.get_table_data(table_name)

        # get primary key of each table
        primary_key = @adapter.get_primary_key(table_name)

        primary_key_value = primary_key.try(:first).try(:[], "column_name")

        tables[table_name][:primary_key] = primary_key_value
        tables[table_name][:indices] = create_index(tables[table_name][:data], primary_key_value)
      end
      tables
    end

    def create_index(rows, primary_key)
      if primary_key
        rows.each_with_index.inject({}) do |dictionary, (row, i)|
          id_val = row[primary_key]
          dictionary[id_val]= i
          dictionary
        end
      else
        {}
      end
    end

    def generate_data_json(tables)
      {
        action_name: "default",
        tables: tables
      }.to_pj
    end

    def write_data_json(data)
      increased_number = get_new_file_number
      File.write("data/#{increased_number}.json", data)
      update_file_number(increased_number)
    end

    def get_new_file_number
      current_number = File.read(FILE_NUMBER_NAME)
      current_number.to_i + 1
    end

    def update_file_number(increased_number)
      File.write(FILE_NUMBER_NAME, increased_number)
    end
  end
end

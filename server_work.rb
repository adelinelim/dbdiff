require "sinatra"
require "sinatra/reloader"
require_relative "initializer"

def compare_one_table(a, b)
  a[:indices].map do |id, i|
    if !b[:indices][id]
      a[:data][i]
    end
  end.compact
end

def compare_one_row_data(r1, r2)
  diff = {}
  r1.each do |k, v|
    if r1[k] != r2[k]
      diff[k] = {
        from: r1[k],
        to: r2[k]
      }
    end
  end
  diff
end

def compare_one_row(r1, r2)
  {
    id: r1[:id],
    row_modification: compare_one_row_data(r1,r2)
  }
end

def add_modification(a, b)
  final_diff = []
  a[:indices].each do |id, i|
    j = b[:indices][id]

    if j
      diff = compare_one_row(a[:data][i], b[:data][j])
      if (diff[:row_modification]).present?
        final_diff << diff
      end
    end
  end
  final_diff
end

def create_index(rows, primary_key)
  rows.each_with_index.inject({}) do |dictionary, (row, i)|
    id_val = row[primary_key]
    dictionary[id_val]= i
    dictionary
  end
end

# this is for modification only because both snapshot have the same table
def compare_tables_for_modification(t1, t2, action, diff)
  perform_only_when_table_exists_in_2_snapshot(t1, t2, diff) do |table_name|
    diff[table_name][action] = compare_one_table(t1[table_name], t2[table_name])
  end
end

# this is for modification only because both snapshot have the same table
def compare_rows_for_modification(t1, t2, diff)
  perform_only_when_table_exists_in_2_snapshot(t1, t2, diff) do |table_name|
    diff[table_name][:modification] = add_modification(t1[table_name], t2[table_name])
  end
end

def perform_only_when_table_exists_in_2_snapshot(t1, t2, diff)
  t1.each do |table_name1, table|
    table2 = t2[table_name1]
    if table2
      diff[table_name1] ||= {}
      yield(table_name1)
    end
  end
end

def compare_tables_for_add_delete(t1, t2, action, diff)
  # shape: [:orders, :campaigns]
  mutated_table_names = (t1.keys - t2.keys)

  mutated_table_names.each do |tname|
    data = t1[tname][:data]
    diff[tname] ||= {}
    diff[tname][action] = data
  end
end

get "/add_connection" do
  erb :'add_connection_view'
end

get "/add" do
  "saving..."
  if params.present?
    Configuration::DatabaseConfigFile.new(params).write_to_db_config
    redirect "/setup"
  else
    "No database connection to add"
  end
end

get "/setup" do
  all_dbs_config = Configuration::DatabaseConfigFile.read
  all_databases_select_tag = Components::ComboBox.new(
    select: {id: "all_databases"}, option: all_dbs_config.keys
  ).render
  erb :'setup_view', locals: { all_databases: all_databases_select_tag }
end

get "/compare" do
  if params.empty? || params[:cid].empty?
    erb :'no_database_selected_view'
  else
    adapter = Adapters::Factory.new(params[:cid]).create

    table_names = adapter.get_all_tables_names

    tables = {}

    table_names.each do |t|
      table_name = t["table_name"].to_sym
      # retrieve data from table
      tables[table_name] = {}
      tables[table_name][:data] = adapter.get_table_data(table_name)

      # get primary key of each table
      primary_key = adapter.get_primary_key(table_name)

      primary_key_value = primary_key.try(:first).try(:[], "column_name")

      tables[table_name][:primary_key] = primary_key_value

      if primary_key_value
        tables[table_name][:indices] = create_index(tables[table_name][:data], primary_key_value)
      else
        tables[table_name][:indices] = {}
      end
    end

    data = {
      action_name: params[:action_name].presence || "default",
      tables: tables
    }.to_pj

    # write data into json file
    filenumber_name = ".filenumber"
    number = File.read(filenumber_name)
    incre_number = number.to_i + 1
    File.write("data/#{incre_number}.json", data)
    File.write(filenumber_name, incre_number)

    all_files = Dir["data/*"]
    # sort all the data json files name
    sorted_nos = all_files.map do |f|
      filenum = f.split('/').last.split('.').first
      if filenum.is_i?
        filenum.to_i
      end
    end.compact.sort

    if sorted_nos.size > 1
      # Always read last 2 files
      # Read File 1
      file1 = "data/#{sorted_nos[-2]}.json"
      compare_1 = File.read(file1).to_data.deep_symbolize_keys
      t1 = compare_1[:tables]

      # Read File 2
      file2 = "data/#{sorted_nos[-1]}.json"
      compare_2 = File.read(file2).to_data.deep_symbolize_keys
      t2 = compare_2[:tables]

      # data comparison
      diff = {}
      # compare table's row add or deletion
      compare_tables_for_modification(t1, t2, :deletion, diff)
      compare_tables_for_modification(t2, t1, :addition, diff)

      # compare add table or delete table
      compare_tables_for_add_delete(t1, t2, :deletion, diff)
      compare_tables_for_add_delete(t2, t1, :addition, diff)

      # compare row modification with same primary_key
      compare_rows_for_modification(t1, t2, diff)

      # compare data without primary_key
      compare_modification_without_primary_key(t1, t2, :deletion, diff)
      compare_modification_without_primary_key(t2, t1, :addition, diff)

      # filter empty diff result
      filtered_diff = filtered_diff_data(diff)

      # write filtered diff to file
      File.write("data/diff.json", filtered_diff.to_pj)

      # filtered_diff = File.read("data/diff.json").to_data.deep_symbolize_keys
      # display in table html format
      diff_in_html(filtered_diff, file1, file2, params)
    else
      redirect "/setup"
    end
  end
end

# to filter empty modification, deletion or addition for diff result
def filtered_diff_data(diff_data)
  diff = {}
  diff_data.each do |table, val|
    if val.values.flatten.present?
      diff[table] ||= {}
      val.each do |mod_key, mod_val|
        if mod_val.present?
          diff[table][mod_key] = mod_val
        end
      end
    end
  end
  diff
end

def diff_in_html(diff_data, file_name1, file_name2, params)
  encoded_params = params.map do |k,v|
    "#{URI::encode(k)}=#{URI::encode(v)}"
  end.join('&')

  display = %[
    <link rel="stylesheet" href="css/new_diff_table.scss" type="text/css" />
    <link rel="stylesheet" href="css/new_table.scss" type="text/css" />
    <script src="javascript/jquery.min.js" type="text/javascript"></script>
    <script src="javascript/dbcompare.js" type="text/javascript"></script>
    <div class="table-title">Compare File 1: "<b>#{file_name1}</b>" and File 2: "<b>#{file_name2}</b>"</div>
    <input type="hidden" id="cid" name="cid" value='#{params[:cid]}'>
    <a href="/setup" class="btn-submit back">Back</a>
    <a href="/compare?#{encoded_params}" class="btn-submit back">Compare</a>
  ]

  if diff_data.blank?
    return display + %[ <div class="table-title">
      <h3>No changes</h3>
      </div>
    ]
  end

  diff_data.each do |table, value|
    value.each do |action_key, action_val|
      display += %[
        <div class="table-title">
          <h3>#{table}</h3>
          <div class="sub-title">#{action_key.capitalize}</div>
        </div>
      ]

      headers = ""
      rows = ""
      if action_key == :modification
        headers = modification_headers(action_val)
        rows = modification_rows(action_val)
      else
        headers = addition_deletion_headers(action_val)
        rows = addition_deletion_rows(action_val)
      end

      display += %[
        <table class="table-fill">
          <thead>
          <tr>
          #{headers}
          </tr>
          </thead>

          <tbody class="table-hover">
          #{rows}
          </tbody>
        </table>
      ]
    end
  end
  display
end

def modification_headers(data)
  headers = ""
  data.first.keys.each do |column_name|
    headers += %[
      <th class="text-left">
      #{(column_name == :row_modification)? "column names" : column_name}
      </th>
    ]
  end
  headers += %[
    <th class="text-left">from</th>
    <th class="text-left">to</th>
  ]
end

def modification_rows(data)
  rows = ""
  data.each do |row|
    rows += "<tr>"
    row.each_with_index do |value, i|
      if i == 0
        # column names
        rows += %[ <td class="text-left">#{value[1]}</td> ]
      else
        # row_modification
        line = value[i]

        #column values
        counter = 0
        rows += %[<td class="text-left">]
        rows += line.map do |k, v|
          counter += 1
          bold_even_line(counter, k)
        end.join("<br>")
        rows += "</td>"

        # from and to values
        from_data = %[<td class="text-left">]
        to_data = %[<td class="text-left">]

        counter = 0
        line.each do |k, v|
          counter += 1
          from_data += bold_even_line(counter, "#{v[:from]} <br>")
          to_data += bold_even_line(counter, "#{v[:to]} <br>")
        end

        from_data += "</td>"
        to_data += "</td>"

        rows += from_data
        rows += to_data
      end
    end
    rows += "</tr>"
  end
  rows
end

def bold_even_line(counter, result)
  if counter % 2 == 0
    result = "<b>#{result}</b>"
  else
    result
  end
end

def addition_deletion_headers(action_val)
  headers = ""
  action_val.first.keys.each do |column_name|
    headers += %[ <th class="text-left">#{column_name}</th> ]
  end
  headers
end

def addition_deletion_rows(action_val)
  rows = ""
  action_val.each do |row|
    rows += "<tr>"
    row.each do |k, v|
      rows += %[ <td class="text-left">#{v}</td> ]
    end
    rows += "</tr>"
  end
  rows
end

def compare_modification_without_primary_key(tables_1, tables_2, action, diff)
  tables_1.each do |table_name, value|
    if tables_1[table_name][:primary_key].nil?
      table2 = tables_2[table_name]
      if table2
        value[:data].each do |row|
          # find the whole row in table 2 exist?
          unless table2[:data].include?(row)
            diff[table_name] ||= {}
            diff[table_name][action] ||= []
            diff[table_name][action] << row
          end
        end
      end
    end
  end
end

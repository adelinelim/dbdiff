require "sinatra"
require "sinatra/reloader"
require "mysql2"
require "pry"
require "rubygems"
require "active_support/all"
require "pg"
require "yaml"
require "hashie"

def read_db_yaml(type, database)
  configs = YAML::load_file("config/#{type}_database.yml")[database.to_s]
end

def initialize_db_conn(db_type, database)
  config = read_db_yaml(db_type, database)
  if config.present?
    if db_type.to_sym == :pg
      # PG::Connection.new(dbname: "postgres")
      PG::Connection.new(config)
    elsif db_type.to_sym == :mysql
      # Mysql2::Client.new(host: "localhost", username: "root")
      Mysql2::Client.new(config)
    else
      raise "The database type is not support"
    end
  else
    raise "Need to set the database connection in *.yml files"
  end
end

class Hash
  def to_pj
    JSON.pretty_generate(self)
  end

  def to_hpj
    "<pre>" + to_pj + "</pre>"
  end

  def to_str
    # to_hpj
    to_pj
  end

  def to_s
    # to_hpj
    to_pj
  end

  def +(other)
    to_str + other.to_str
  end
end

class Array
  def to_pj
    JSON.pretty_generate(self)
  end

  def to_hpj
    "<pre>" + to_pj + "</pre>"
  end

  def to_str
    # to_hpj
    to_pj
  end

  def to_s
    # to_hpj
    to_pj
  end
end

class String
  def to_data
    JSON.parse(self)
  end

  def color(code)
    "\e[38;5;#{code}m#{self}\e[0m"
  end

  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end

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

def get_databases_select_tag(type, database_name)
  conn = initialize_db_conn(type, database_name)
  result = yield(conn)
  databases = result.map do |row|
    row["database_name"]
  end
  generate_select_tag(databases, type)
end

def generate_select_tag(list, id)
  option = ""
  list.each do |db|
    option += "<option value='#{db}'>#{db}</option>"
  end
  "<select hidden='true' id='#{id}'>#{option}</select>"
end

get "/hi" do
  mysql_select_tag = get_databases_select_tag(:mysql, :default) do |conn|
    query = "SELECT DISTINCT table_schema AS database_name FROM information_schema.tables"
    conn.query(query).to_a
  end

  pg_select_tag = get_databases_select_tag(:pg, :default) do |conn|
    query = "SELECT datname AS database_name FROM pg_database WHERE datistemplate = false"
    conn.exec(query).to_a
  end

  %[
    <link rel="stylesheet" href="diff_table.scss" type="text/css" />
    <link rel="stylesheet" href="input.scss" type="text/css" />
    <link rel="stylesheet" href="select.scss" type="text/css" />
    <script src="jquery.min.js" type="text/javascript"></script>
    <script src="dbdiff.js" type="text/javascript"></script>

    <form action="/db_compare" method="post">
      <div class="table-title">
        <h3>Database Type:</h3>
        <select id="db_type">
          <option value="pg">postgres</option>
          <option value="mysql">mysql</option>
        </select>
        <h3>Database Name:</h3>
        #{pg_select_tag}
        #{mysql_select_tag}
        <h3>Action Name: </h3>
        <input type="text" id="action_name" name="action_name">
        <input type="hidden" id="parameters" name="parameters">
        <input id="compare" type="submit" class="myButton" value="Compare">
      </div>
    </form>
  ]
end

def get_tables_names(type, database, conn)
  # get all tables name and ignore views
  sql = %[
    SELECT table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
  ]
  if type.to_sym == :pg
    sql += %[
      AND table_schema = 'public'
      AND table_catalog = '#{database}';
    ]
    conn.exec(sql)
  else
    sql += "AND table_schema = '#{database}';"
    conn.query(sql)
  end
end

def get_primary_key(type, database, table, conn)
  # get primary key of table
  sql = %[
    SELECT k.column_name
    FROM information_schema.table_constraints t
    JOIN information_schema.key_column_usage k
    USING(constraint_name,table_schema,table_name)
    WHERE t.constraint_type='PRIMARY KEY'
  ]
  if type.to_sym == :pg
      sql += %[
      AND t.table_schema='public'
      AND t.table_name='#{table}'
      AND t.table_catalog = '#{database}';
    ]
    conn.exec(sql)
  else
    sql += %[
      AND t.table_schema='#{database}'
      AND t.table_name='#{table}';
    ]
    conn.query(sql)
  end
end

def get_table_data(type, table_name, conn)
  # retrieve data from table
  sql = "SELECT * FROM #{table_name}"
  if type.to_sym == :pg
    conn.exec(sql)
  else
    conn.query(sql)
  end
end

post "/db_compare" do
  if params[:parameters].empty?
    raise "no parameters!"
  end

  db_params = Hashie::Mash.new(JSON.parse(params[:parameters]))
  type = db_params.db_type
  database = db_params.database

  conn = initialize_db_conn(type, database)
  table_names = get_tables_names(type, database, conn).to_a

  tables = {}

  table_names.each do |t|
    table_name = t["table_name"].to_sym
    # retrieve data from table
    tables[table_name] = {}
    tables[table_name][:data] = get_table_data(type, table_name, conn).to_a

    # get primary key of each table
    primary_key = get_primary_key(type, database, table_name, conn).to_a

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
  # sorted_nos = all_files.map {|f| f.split('/').last.split('.').first.to_i }.sort

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
    diff_in_html(filtered_diff, file1, file2)
  else
    # %[
    #   <script type="text/javascript">
    #     alert("first json data generated");
    #   </script>
    # ]

    redirect "/hi"
    # generate first json data
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

def diff_in_html(diff_data, file_name1, file_name2)
  display = %[
    <link rel="stylesheet" href="diff_table.scss" type="text/css" />
    <div class="table-title">Compare File 1: "<b>#{file_name1}</b>" and File 2: "<b>#{file_name2}</b>"</div>
  ]

  if diff_data.empty?
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

# diff shape
# {
#   "campaigns": {
#     addition: [{id: 13, url_key: 'itsonus', content: "lala 1"}],
#     modifications: [
#       {
#         id: 8,
#         row_modification: {
#           url_key: {from: '', to: ''},
#           content: {from: '', to: ''}
#         }
#       }
#     ],
#     deletions: [...]
#   },
#   "orders": {
#     deleteTable: true,
#     deletion: [....]
#   },
#   "ordeaars": {
#     addedTable: true,
#     addition: [....]
#   }
# }

# TODO:
# 1. refactor

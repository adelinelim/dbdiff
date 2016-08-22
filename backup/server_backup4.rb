require "sinatra"
require "sinatra/reloader"
require "mysql2"
require "pry"
require 'rubygems'
require 'active_support/all'

class Hash
  def to_pj
    JSON.pretty_generate(self)
  end

  def to_hpj
    "<pre>" + to_pj + "</pre>"
  end

  def to_str
    to_hpj
  end

  def to_s
    to_hpj
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
    to_hpj
  end

  def to_s
    to_hpj
  end
end

class String
  def to_data
    JSON.parse(self)
  end

  def color(code)
    "\e[38;5;#{code}m#{self}\e[0m"
  end
end

database = "fulcrum_development"

# setup DB connection
client = Mysql2::Client.new(
  host: "localhost",
  username: "root",
  database: database
)

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

get '/hi' do
  # # get all tables name and ignore views
  # table_names = client.query(
  #   %[
  #     SELECT table_name
  #     FROM information_schema.tables
  #     WHERE table_type = 'BASE TABLE'
  #     AND table_schema = '#{database}';
  #   ]
  # ).to_a
  #
  # tables = {}
  #
  # table_names.each do |t|
  #   table_name = t["table_name"].to_sym
  #   # retrieve data from table
  #   tables[table_name] = {}
  #   tables[table_name][:data] = client.query("SELECT * FROM #{table_name}").to_a
  #
  #   # get primary key of each table
  #   primary_key = client.query(
  #     "SELECT k.column_name
  #     FROM information_schema.table_constraints t
  #     JOIN information_schema.key_column_usage k
  #     USING(constraint_name,table_schema,table_name)
  #     WHERE t.constraint_type='PRIMARY KEY'
  #       AND t.table_schema='#{database}'
  #       AND t.table_name='#{table_name}';"
  #   ).to_a
  #
  #   primary_key_value = primary_key.try(:first).try(:[], "column_name")
  #
  #   tables[table_name][:primary_key] = primary_key_value
  #
  #   if primary_key_value
  #     tables[table_name][:indices] = create_index(tables[table_name][:data], primary_key_value)
  #   else
  #     tables[table_name][:indices] = {}
  #   end
  # end
  #
  # data = {
  #   action_name: 'story page',
  #   tables: tables
  # }.to_pj
  #
  # # write data into json file
  # filenumber_name = ".filenumber"
  # number = File.read(filenumber_name)
  # incre_number = number.to_i + 1
  # File.write("data/#{incre_number}.json", data)
  # File.write(filenumber_name, incre_number)
  #
  # all_files = Dir["data/*"]
  # # sort all the data json files name
  # sorted_nos = all_files.map {|f| f.split('/').last.split('.').first.to_i }.sort
  #
  # # Always read last 2 files
  # # Read File 1
  # compare_1 = File.read("data/#{sorted_nos[-2]}.json").to_data.deep_symbolize_keys
  # t1 = compare_1[:tables]
  #
  # # Read File 2
  # compare_2 = File.read("data/#{sorted_nos[-1]}.json").to_data.deep_symbolize_keys
  # t2 = compare_2[:tables]
  #
  # # data comparison
  # diff = {}
  # # compare table's row add or deletion
  # compare_tables_for_modification(t1, t2, :deletion, diff)
  # compare_tables_for_modification(t2, t1, :addition, diff)
  #
  # # compare add table or delete table
  # compare_tables_for_add_delete(t1, t2, :deletion, diff)
  # compare_tables_for_add_delete(t2, t1, :addition, diff)
  #
  # # compare row modification with same primary_key
  # compare_rows_for_modification(t1, t2, diff)
  #
  # # filter empty diff result
  # filtered_diff = filtered_diff_data(diff)
  #
  # # write diff to file
  # File.write("data/diff.json", filtered_diff.to_pj)

  filtered_diff = File.read("data/diff.json").to_data.deep_symbolize_keys
  # display in table html format
  diff_in_html(filtered_diff)
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

def diff_in_html(diff_data)
  display = %[
    <script src="jquery.js" type="text/javascript">
    </script>

    <link rel="stylesheet" href="diff_table.scss" type="text/css" />
  ]
  diff_data.each do |table, value|
    value.each do |action_key, action_val|
      display += %[
        <div class="table-title">
          <h3>#{table}</h3>
          <div class="sub-title">#{action_key.capitalize}</div>
        </div>
      ]

      headers = ""
      action_val.first.keys.each do |column_name|
        # TODO if column_name is row_modification
        headers += %[ <th class="text-left">#{column_name}</th> ]
      end

      rows = ""
      action_val.each do |row|
        rows += "<tr>"
        row.each do |k, v|
          rows += %[ <td class="text-left">#{v}</td> ]
        end
        rows += "</tr>"
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

# TODO:
# 1. Design UI
# 2. compare data without primary_key

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

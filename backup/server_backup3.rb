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
end

database = "fulcrum_development"

# setup DB connection
client = Mysql2::Client.new(
  host: "localhost",
  username: "root",
  database: database
)

def create_index(rows, primary_key)
  rows.each_with_index.inject({}) do |dictionary, (row, i)|
    dictionary[row[primary_key.to_sym]]= i
    dictionary
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
    modification: compare_one_row_data(r1,r2)
  }
end

def add_modification(a, b)
  final_diff = []
  a[:indices].each do |id, i|
    j = b[:indices][id]

    if j
      diff = compare_one_row(a[:data][i], b[:data][j])
      if (diff[:modification]).present?
        final_diff << diff
      end
    end
  end
  final_diff
end

def mass_create_index(tables)
  result = tables.map do |table_name, table|
    primary_key = table[:primary_key]

    if primary_key
      new_table = table.dup
      new_table[:indices] = create_index(table[:data], primary_key)
      [table_name, new_table]
    else
      [table_name, table]
    end
  end

  Hash[result]
end


# this is for modification only becoz both snapshot have the same table
def compare_tables_for_modification(indexed_ts1, indexed_ts2, action, diff)
  perform_only_when_table_exists_in_2_snapshot(indexed_ts1, indexed_ts2, diff) do |table_name|
    diff[table_name][action] = compare_one_table(indexed_ts1[table_name], indexed_ts2[table_name])
  end
end

# this is for modification only becoz both snapshot have the same table
def compare_rows_for_modification(indexed_ts1, indexed_ts2, diff)
  perform_only_when_table_exists_in_2_snapshot(indexed_ts1, indexed_ts2, diff) do |table_name|
    diff[table_name][:modification] = add_modification(indexed_ts1[table_name], indexed_ts2[table_name])
  end
end

def perform_only_when_table_exists_in_2_snapshot(indexed_ts1, indexed_ts2, diff)
  indexed_ts1.each do |table_name1, table|
    table2 = indexed_ts2[table_name1]
    if table2
      diff[table_name1] ||= {}
      yield(table_name1)
    end
  end
end




def compare_tables_for_add_delete(indexed_ts1, indexed_ts2, action, diff)
  # shape: [:orders, :campaigns]
  mutated_table_names = (indexed_ts1.keys - indexed_ts2.keys)

  mutated_table_names.each do |tname|
    data = indexed_ts1[tname][:data]
    diff[tname] ||= {}
    diff[tname][action] = data
  end
end




get '/hi' do
  # get all tables name and ignore views
  table_names = client.query(
    %[
      SELECT table_name
      FROM information_schema.tables
      WHERE table_type = 'BASE TABLE'
      AND table_schema = '#{database}';
    ]
  ).to_a

  tables = {}

  table_names.each do |t|
    table_name = t["table_name"].to_sym
    # retrieve data from table
    tables[table_name] = {}
    tables[table_name][:data] = client.query("SELECT * FROM #{table_name}").to_a

    # get primary key of each table
    primary_key = client.query(
      "SELECT k.column_name
      FROM information_schema.table_constraints t
      JOIN information_schema.key_column_usage k
      USING(constraint_name,table_schema,table_name)
      WHERE t.constraint_type='PRIMARY KEY'
        AND t.table_schema='#{database}'
        AND t.table_name='#{table_name}';"
    ).to_a
    tables[table_name][:primary_key] = primary_key.try(:first).try(:[], "column_name")
  end

  data = {
    action_name: 'story page',
    tables: tables
  }.to_pj

  # write data into json file
  number = File.read('.filenumber')
  incre_number = number.to_i + 1
  File.write("data/#{incre_number}.json", data)
  File.write('.filenumber', incre_number)


  # Read File 1
  compare_1 = File.read("data/3.json").to_data.deep_symbolize_keys
  t1 = compare_1[:tables]
  indexed_ts1 = mass_create_index(t1)

  # # Read File 2
  compare_2 = File.read("data/4.json").to_data.deep_symbolize_keys
  t2 = compare_2[:tables]
  indexed_ts2 = mass_create_index(t2)

  # modification
  diff = {}
  compare_tables_for_modification(indexed_ts1, indexed_ts2, :deletion, diff)
  compare_tables_for_modification(indexed_ts2, indexed_ts1, :addition, diff)

  compare_tables_for_add_delete(indexed_ts1, indexed_ts2, :deletion, diff)
  compare_tables_for_add_delete(indexed_ts2, indexed_ts1, :addition, diff)
  #
  #
  compare_rows_for_modification(indexed_ts2, indexed_ts1, diff)

  diff.to_hpj
end

# {
#   "campaigns": {
#     addition: [{id: 13, url_key: 'itsonus', content: "lala 1"}],
#     modifications: [
#       {
#         id: 8,
#         modification: {
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

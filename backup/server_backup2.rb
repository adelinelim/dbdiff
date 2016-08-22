# http://www.sinatrarb.com/
# https://www.digitalocean.com/community/tutorials/how-to-install-and-get-started-with-sinatra-on-your-system-or-vps

require "sinatra"
require "sinatra/reloader"
require "mysql2"
# require "json"
require "pry"

require 'rubygems'
# require 'bundler/setup'

require 'active_support/all'
# require 'action_view'

class Hash
  def to_pj
    JSON.pretty_generate(self)
  end

  def to_hpj
    "<pre>" + to_pj + "</pre>"
  end

  def to_str
    inspect
    # to_hpj
  end

  def to_s
    inspect
    # to_hpj
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
    inspect
    # to_hpj
  end

  def to_s
    inspect
    # to_hpj
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
    if b[:indices][id]
      diff = compare_one_row(a[:data][i], b[:data][i])
      if (diff[:modification]).present?
        final_diff << diff
      end
    end
  end
  final_diff
end

get '/meow' do
  a = {'hello' => '999'}
  a = a.deep_symbolize_keys
  a.inspect
end

get '/hi' do
  # get all tables name and ignore views
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
  #   tables[table_name][:primary_key] = primary_key.try(:first).try(:[], "column_name")
  # end
  #
  # data = {
  #   action_name: 'story page',
  #   tables: tables
  # }.to_pj
  #
  # # write data into json file
  # number = File.read('.filenumber')
  # incre_number = number.to_i + 1
  # File.write("data/#{incre_number}.json", data)
  # File.write('.filenumber', incre_number)


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

  # loop through each tables to create index for file 2
  # t2.each do |table, v|
  #   primary_key = t2[table][:primary_key]
  #   if primary_key.present?
  #     # create indices
  #     indices = create_index(t2[table][:data], primary_key)
  #     t2[table][:indices] = indices
  #   end
  # end

  # Read File 1
  compare_1 = File.read("data/3.json").to_data.deep_symbolize_keys
  t1 = compare_1[:tables]
  indexed_ts1 = mass_create_index(t1)

  # # Read File 2
  compare_2 = File.read("data/4.json").to_data.deep_symbolize_keys
  t2 = compare_2[:tables]
  indexed_ts2 = mass_create_index(t2)

  deleted_table_names = (indexed_ts1.keys - indexed_ts2.keys).to_s
  added_table_names = (indexed_ts2.keys - indexed_ts1.keys).to_s

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


# b1 = indexed_ts1[:beneficiaries]
# b2 = indexed_ts2[:beneficiaries]
#
# delta = b1[:indices].keys - b2[:indices].keys
#
# delta.map do |d|
#   i = b1[:indices][d]
#   b1[:data][i]
# end.to_s

  # modification

  indexed_ts1.each do |table_name1, table|
    table2 = indexed_ts2[table_name1]
    if table2
      # compare_one_table(indexed_ts1[table_name1], table2).to_hpj
    end
  end

  "ok"
  # Assume no DB schema changes

  # TODO nil primary_key
  # TODO change hash key to symbolic not string
  # TODO modify UI

# {
#   "action_name": "story page",
#   "tables": {
#     "address_components": {
#       "data": [
#         {"id": 1, "name": "lala"},
#         {"id": 2, "name": "lala 2"},
#       ],
#       "primary_key": "id",
#       indices: {"1"=>0, "2"=>1}
#     },
#     "users": {
#       "data": [
#         {"id": 1, "name": "user 1"},
#         {"id": 2, "name": "user 2"},
#       ],
#       "primary_key": "id",
#       indices: {"1"=>0, "2"=>1}
#     }
#   }
# }

  # diff = {}
  # diff[:deletion] = []
  #
  # # loop through each tables's indices to check for addition, deletion or modification
  # t1.each do |k, v|
  #   table1 = t1[k]
  #   table1_indices = table1[:indices]
  #
  #   if table1_indices.present?
  #     table2 = t2[k]
  #     if table2.presence[:indices].present?
  #       p compare_one_table(table1, table2)
  #     end
  #   end
  # end

  # p diff

#   t1 + t2
#
#
# # t1['campaigns'][:indices].keys
# b1 = t1[:beneficiaries]
# b2 = t2[:beneficiaries]
#
# b1[:indices]
  # %[
  # #{JSON.pretty_generate(result)}
  # Action Name: <input type="text" name="fname">
  # <button type="button">Save</button>
  # <br>
  # <br>
  # Diff Action File 1:
  # <select>
  #   <option value="volvo">Volvo</option>
  #   <option value="saab">Saab</option>
  #   <option value="mercedes">Mercedes</option>
  #   <option value="audi">Audi</option>
  # </select>
  #
  # Diff Action File 2:
  # <select>
  #   <option value="volvo">Volvo</option>
  #   <option value="saab">Saab</option>
  #   <option value="mercedes">Mercedes</option>
  #   <option value="audi">Audi</option>
  # </select>
  # <button type="button">Diff DB</button>
  # ]
end


# Save DB data
# - save data into log file JSON format and provide db set number
#
# Diff DB data
# - can compare db set number with another set number's data
# - added data - green color
# - deleted data - red color

# 1.log
# {
#   action_name: 'story page',
#   tables: {
#     campaigns: [
#       {url_key: "abc", id: 1},
#       {url_key: "something", id: 2},
#     ],
#     orders:[...]
#   }
# }

# 1.log changes
# {
#   action_name: 'story page',
#   tables: {
#     campaigns: {
#       data: [
#         {url_key: "abc", id: 11},
#         {url_key: "something", id: 23},
#       ],
#       primary_key: "url_key",
#       indices: {
#         "abc": 0,
#         "something": 1,
#
#       }
#     },
#     orders: {
#       data: [
#         {type: "bulk", id: 1},
#         {type: "drop", id: 2},
#       ],
#       primary_key: "id",
#       indices: {
#         "1": 0,
#         "2": 1,
#
#       }
#     }
#   }
# }

# table_primary_key
# {
#   "address_components"=>"id",
#   "analytic_tracks"=>nil,
#   "articles"=>"id"
# }

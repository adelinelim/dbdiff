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
    table_name = t["table_name"]
    # retrieve data from table
    tables[table_name] = client.query("SELECT * FROM #{table_name}").to_a
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
  compare_1 = File.read("data/1.json").to_data
  tables_compare = compare_1["tables"]

  # get table primary key
  table_primary_key = {}
  tables_compare.each do |k,v|
    primary_key = client.query(
      "SELECT k.column_name
      FROM information_schema.table_constraints t
      JOIN information_schema.key_column_usage k
      USING(constraint_name,table_schema,table_name)
      WHERE t.constraint_type='PRIMARY KEY'
        AND t.table_schema='#{database}'
        AND t.table_name='#{k}';"
    ).to_a
    table_primary_key[k] = primary_key.try(:first).try(:[], "column_name")
  end

  # Read File 2
  compare_2 = File.read("data/2.json").to_data

  # Assume no DB schema changes

  # Data Comparison between File 1 and File 2


  "ok"

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
#         {url_key: "abc", id: 1},
#         {url_key: "something", id: 2},
#       ],
#       primary_key: "id"
#     },
#     orders: {
#       data: [
#         {type: "bulk", id: 1},
#         {type: "drop", id: 2},
#       ],
#       primary_key: "id"
#     }
#   }
# }

# table_primary_key
# {
#   "address_components"=>"id",
#   "analytic_tracks"=>nil,
#   "articles"=>"id"
# }

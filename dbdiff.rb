require "sinatra"
require "sinatra/reloader"
require_relative "initializer"

get "/add_connection" do
  erb :'add_connection_view'
end

get "/add" do
  "saving..."
  if params.present?
    Configuration::DatabaseConfigFile.new(params).write_to_db_config
    redirect "/setup"
  else
    erb :'no_database_conn_params_view'
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
    diff_data_params = Services::ParamsGenerator.new(params).generate_diff_params
    Services::DataGenerator.new(params).generate
    diff_generator = Services::DiffGenerator.new
    diff_generator.generate
    table_data_diff = ""
    if diff_generator.has_two_data_files?
      table_data_diff = Services::DiffViewer.new(diff_generator.get_filtered_diff).generate
    else
      table_data_diff = "The first data file is generated, click Compare button again to generate another data file to compare"
    end
    erb :'compare_view', locals: {
      diff_data: diff_data_params,
      file_names:  diff_generator.get_data_files_names,
      table_data_diff: table_data_diff
    }
  end
end

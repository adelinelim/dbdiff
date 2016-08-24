module Services
  class DataComparison
    DIFF_FILE = "data/diff.json"

    def initialize(table1, table2)
      @table1 = table1
      @table2 = table2
    end

    def generate
      diff = compare_data
      write_to_diff_file(diff)
      diff
    end

    private

    def compare_data
      diff = {}
      # compare table's row add or deletion
      compare_tables_for_modification(@table1, @table2, :deletion, diff)
      compare_tables_for_modification(@table2, @table1, :addition, diff)

      # compare add table or delete table
      compare_tables_for_add_delete(@table1, @table2, :deletion, diff)
      compare_tables_for_add_delete(@table2, @table1, :addition, diff)

      # compare row modification with same primary_key
      compare_rows_for_modification(@table1, @table2, diff)

      # compare data without primary_key
      compare_modification_without_primary_key(@table1, @table2, :deletion, diff)
      compare_modification_without_primary_key(@table2, @table1, :addition, diff)

      # filter empty diff result
      diff = filtered_diff_data(diff)
      diff
    end

    def write_to_diff_file(diff)
      File.write(DIFF_FILE, diff.to_pj)
    end

    # this is for modification only because both snapshot have the same table
    def compare_tables_for_modification(t1, t2, action, diff)
      perform_only_when_table_exists_in_2_snapshot(t1, t2, diff) do |table_name|
        diff[table_name][action] = compare_one_table(t1[table_name], t2[table_name])
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
  end
end

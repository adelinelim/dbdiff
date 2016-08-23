module Comparison
  class DataComparison
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
  end
end

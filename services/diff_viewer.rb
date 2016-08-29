module Services
  class DiffViewer
    def initialize(diff_generator)
      @diff_data = diff_generator.get_filtered_diff
      @has_two_data_files = diff_generator.has_two_data_files?
    end

    def generate
      if @has_two_data_files
        if @diff_data.present?
          display_diff
        else
          display_no_changes
        end
      else
        display_no_data_file_message
      end
    end

    private

    def display_no_data_file_message
      "There is no previous data file to compare, "\
      "you will need to click Compare button again "\
      "to generate the next data file to start the data comparison."
    end

    def display_no_changes
      Components::Div.new(class: "table-title") do |d|
        d.tag(tag: "h3", content: "No changes")
      end.render
    end

    def display_diff
      display = ""
      @diff_data.each do |table, value|
        value.each do |action_key, action_val|
          display += Components::Div.new(class: "table-title") do |d|
            d.tag(tag: "h3", content: table)
            d.div(class: "sub-title", content: action_key.capitalize)
          end.render

          headers = ""
          rows = ""
          if action_key == :modification
            headers = modification_headers(action_val)
            rows = modification_rows(action_val)
          else
            headers = addition_deletion_headers(action_val)
            rows = addition_deletion_rows(action_val)
          end

          display += Components::Table.new(class: "table-fill", thead: headers, tbody: rows).render
        end
      end
      display
    end

    def modification_headers(data)
      headers = ""
      data.first.keys.each do |column_name|
        headers += generate_table_header(column_name == :row_modification ? "column names" : column_name)
      end
      headers += generate_table_header("from")
      headers += generate_table_header("to")
    end

    def generate_table_header(content)
      Components::TableHeader.new(class: "text-left", content: content).render
    end

    def generate_table_data(content)
      Components::TableData.new(class: "text-left", content: content).render
    end

    def generate_open_tag_table_data
      %[<td class="text-left">]
    end

    def modification_rows(data)
      rows = ""
      data.each do |row|
        rows += "<tr>"
        row.each_with_index do |value, i|
          if i == 0
            # column names
            rows += generate_table_data(value[1])
          else
            # row_modification
            line = value[i]

            #column values
            counter = 0
            rows += generate_open_tag_table_data
            rows += line.map do |k, v|
              counter += 1
              bold_even_line(counter, k)
            end.join("<br>")
            rows += "</td>"

            # from and to values
            from_data = generate_open_tag_table_data
            to_data = generate_open_tag_table_data

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
        headers += generate_table_header(column_name)
      end
      headers
    end

    def addition_deletion_rows(action_val)
      rows = ""
      action_val.each do |row|
        rows += "<tr>"
        row.each do |k, v|
          rows += generate_table_data(v)
        end
        rows += "</tr>"
      end
      rows
    end
  end
end

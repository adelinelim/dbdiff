module Services
  class DiffViewer
    def initialize(diff_data)
      @diff_data = diff_data
    end

    def generate
      if @diff_data.present?
        display_diff
      else
        display_no_changes
      end
    end

    private

    def display_no_changes
      %[
        <div class="table-title">
        <h3>No changes</h3>
        </div>
      ]
    end

    def display_diff
      display = ""
      @diff_data.each do |table, value|
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
  end
end

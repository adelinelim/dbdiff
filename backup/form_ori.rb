# # Form.new.
# #   input(:aa).
# #   input(:gggb).
# #   submit_button
# #
# #
# # Datagrid.new().render
#
# # <form action="/db_compare" method="post">
# #   <div class="table-title">
# #     <h3>Database Type:</h3>
# #     <select id="db_type">
# #       <option value="pg">postgres</option>
# #       <option value="mysql">mysql</option>
# #     </select>
# #     <h3>Database Name:</h3>
# #     #{pg_select_tag}
# #     #{mysql_select_tag}
# #     <h3>Action Name: </h3>
# #     <input type="text" id="action_name" name="action_name">
# #     <input type="hidden" id="parameters" name="parameters">
# #     <input id="compare" type="submit" class="myButton" value="Compare">
# #   </div>
# # </form>o
#
#
# # Form.new.
# #   input(:aa).
# #   input(:gggb).
# #
#
# require_relative "./initializer"
#
# module FormComponent
#   class Text
#     def initialize(attributes)
#       @attributes = attributes
#     end
#
#     def perform
#       tag = "<input"
#
#       tag += @attributes.map do |k, v|
#         " #{k}='#{v}'"
#       end.join
#
#       tag + ">"
#     end
#   end
#
#   class ComboBox
#     def initialize(attributes)
#       @attributes = attributes
#     end
#
#     def perform
#       tag = "<select"
#       @attributes[:select].each do |k, v|
#         tag += " #{k}='#{v}'"
#       end
#       tag += ">"
#
#       standarized_options = option_canonicalizer(@attributes[:option])
#
#       string_options = standarized_options.map do |k|
#         "<option value='#{k[0]}'>#{k[1]}</option>"
#       end.join
#
#       tag + string_options + "</select>"
#     end
#
#     private
#
#     def option_canonicalizer(raw_options)
#       raw_options.map do |option|
#         if option.is_a? String
#           # to convert string to array form
#           [option, option]
#         else
#           option
#         end
#       end
#     end
#   end
#
#   class Tag
#     def initialize(values)
#       @tag = values[:tag]
#       @attributes = values[:attributes]
#       @content = values[:content]
#     end
#
#     def perform
#       attribute = ""
#       if @attributes.present?
#         attribute = @attributes.map do |k, v|
#           " #{k}='#{v}'"
#         end.join
#       end
#
#       result = "<#{@tag}#{attribute}>"
#       result += "#{@content}"
#       result + "</#{@tag}>"
#     end
#   end
#
#   class Customize
#     def initialize(content)
#       @content = content
#     end
#
#     def perform
#       @content
#     end
#   end
# end
#
#
#
# class Form
#   FORM_COMPONENT = "FormComponent"
#
#   def initialize(options = {})
#     @options = options
#     @commands = []
#     yield(self)
#   end
#
#   def text(attributes)
#     attributes = {attributes: attributes}
#     @commands << attributes.merge(type: :text)
#   end
#
#   def combo_box(attributes)
#     attributes = {attributes: attributes}
#     @commands << attributes.merge(type: :combo_box)
#   end
#
#   def customize(attributes)
#     attributes = {attributes: attributes}
#     @commands << attributes.merge(type: :customize)
#   end
#
#   def tag(attributes)
#     attributes = {attributes: attributes}
#     @commands << attributes.merge(type: :tag)
#   end
#
#   def render
#     materialize_components = []
#     @commands.each do |c|
#       materialize_components << generate_class(c[:type]).new(c[:attributes]).perform
#     end
#     materialize_components
#   end
#
#   private
#
#   def generate_class(type)
#     get_form_name(type).constantize
#   end
#
#   def get_form_name(type)
#     "#{FORM_COMPONENT}::#{type.to_s.camelize}"
#   end
# end
#
# test = Form.new(action: '/db_compare') do |f|
#   f.customize("<div>")
#   f.text(id: "so", class: "aaa-aaa fff jj")
#   f.text(id: "action_name", name: "action_name")
#   f.tag(tag: "h3", content: "Database Name:")
#   f.tag(tag: "h3", attributes: {class: "kls"}, content: "Database Name:")
#   f.text(id: "action_name2", name: "action_name2")
#   f.combo_box(select: {id: "db_type"}, option: [['t', 'transgender'], 'female', 'male' ])
#   f.customize("</div>")
# end.render
#
# # def transformer(rows, value_field_name, display_field_name)
# #   [{id: 1, full_name: 'aaron'},{}].map do |row|
# #     [row[value_field_name], row[display_field_name]]
# #   end
# # end
# # transformer(rows, :id, :full_name)
# # [[1, 'lala']]
#
#
# # <option value="1">lala</option>
#
# puts test
#
# # form = Form.new.......
# # form = form.input(:non_profit) if
# #
# # campaign_form = Form.new(aa: 99).input(:assdd)
# #
# # campaign_form_for_non_profit = campaign_form.input(:nonprofit_ein) if bla
# #
# # f = Form.new(:lala => 123).bla
# # one_form = f.one
# # two_foorm = f.two

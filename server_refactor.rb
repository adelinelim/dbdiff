require_relative "./initializer"
require "sinatra"
require "sinatra/reloader"

get "/dbsetup" do
  header_content = Components::Head.new do |h|
    h.link(rel: "stylesheet", href: "diff_table.scss", type: "text/css")
    h.link(rel: "stylesheet", href: "input.scss", type: "text/css")
    h.link(rel: "stylesheet", href: "select.scss", type: "text/css")
    h.script(src: "jquery.min.js", type: "text/javascript")
    h.script(src: "dbdiff.js", type: "text/javascript")
  end.render

  

  body_content = Components::Form.new(action: "/db_compare", method: "post") do |f|
    f.div(class: "table-title") do |d|
      d.tag(tag: "h3", content: "Database Type:")
      d.combo_box(select: {id: "db_type"}, option: [["pg", "postgres"], "mysql"])
      d.tag(tag: "h3", content: "Database Name:")
      # pg select tag
      d.customize()
      # mysql select tag
      d.tag(tag: "h3", content: "Action Name:")
      d.text(type: "text", id: "action_name", name: "action_name")
      d.text(type: "hidden", id: "parameters", name: "parameters")
      d.text(type: "submit", id: "compare", class: "myButton", value: "compare")
    end
  end.render

  header_content + body_content
end

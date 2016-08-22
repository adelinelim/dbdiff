require_relative "./initializer"
require "sinatra"
require "sinatra/reloader"

get "/hi" do
  header_content = HtmlComponent::HeaderGenerator.new do |h|
    h.link(rel: "stylesheet", href: "diff_table.scss", type: "text/css")
    h.link(rel: "stylesheet", href: "input.scss", type: "text/css")
    h.link(rel: "stylesheet", href: "select.scss", type: "text/css")
    h.script(src: "jquery.min.js", type: "text/javascript")
    h.script(src: "dbdiff.js", type: "text/javascript")
  end.render

  # h.form do |f|
  #   f.div do |d|
  #     d.combo_box()
  #     d.combo_box()
  #     d.combo_box()
  #     d.combo_box()
  #     d.combo_box()
  #     d.combo_box()
  #   end
  # end

  body_content = HtmlComponent::FormGenerator.new(action: "/db_compare", method: "post") do |f|
    f.customize do
      HtmlComponent::DivGenerator.new(class: "table-title") do |d|
        d.tag(tag: "h3", content: "Database Type:")
        d.combo_box(select: {id: "db_type"}, option: [["pg", "postgres"], "mysql"])
        d.tag(tag: "h3", content: "Database Name:")
        # d.combo_box()
        # d.combo_box(select: )
        # pg select tag
        # mysql select tag
        d.tag(tag: "h3", content: "Action Name:")
        d.text(type: "text", id: "action_name", name: "action_name")
        d.text(type: "hidden", id: "parameters", name: "parameters")
        d.text(type: "submit", id: "compare", class: "myButton", value: "compare")
      end.render
    end
  end.render

  header_content + body_content
end

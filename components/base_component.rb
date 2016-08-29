module Components
  class BaseComponent
    def initialize(options = {})
      @children = []
      @options = options
      yield(self) if block_given?
    end

    def add(child)
      @children << child
    end

    def render
      raise "to be implemented"
    end

    def div(*args, &block)
      add(Div.new(*args, &block))
    end

    def form(*args, &block)
      add(Form.new(*args, &block))
    end

    def script(*args, &block)
      add(Script.new(*args, &block))
    end

    def link(*args, &block)
      add(Link.new(*args, &block))
    end

    def head(*args, &block)
      add(Head.new(*args, &block))
    end

    def customize(args)
      add(Customize.new(args))
    end

    def text(args)
      add(Text.new(args))
    end

    def tag(args)
      add(Tag.new(args))
    end

    def combo_box(args)
      add(ComboBox.new(args))
    end

    def table(*args, &block)
      add(Table.new(*args, &block))
    end

    def tbl_head(*args, &block)
      add(TblHead.new(*args, &block))
    end

    def tbl_body(*args, &block)
      add(TblBody.new(*args, &block))
    end
  end
end

# root = Components::Form.new(attributes: {class: "lala"}) do |f|
#   f.div(content: "hello world")
#   f.div(content: "meow", attributes: {class: "meow-class", hidden: true})
#   f.div do |x|
#     x.div(content: "lulu")
#     x.text(content: "lolo")
#     x.customize("<pre>test</pre>")
#     f.combo_box(select: {id: "db_type"}, option: [['t', 'transgender'], 'female', 'male' ])
#     x.tag(tag: "h3", content: "something", attributes: { class: "merry-tag" })
#   end
# end
# puts root.render
# <form class='lala'>
#   <div>hello world</div>
#   <div class='meow-class' hidden='true'>meow</div>
#   <div>
#     <div>lulu</div>
#     <input content='lolo'>
#     <pre>test</pre>
#     <select id='db_type'>
#       <option value='t'>transgender</option>
#       <option value='female'>female</option>
#       <option value='male'>male</option>
#     </select>
#     <h3 class='merry-tag'>something</h3>
#   </div>
# </form>

# head = Components::Head.new(attributes: {class: "lala"}) do |h|
#   h.link(rel: "stylesheet", href: "diff_table.scss", type: "text/css")
#   h.link(rel: "stylesheet", href: "input.scss", type: "text/css")
#   h.link(rel: "stylesheet", href: "select.scss", type: "text/css")
#   h.script(attributes: {src: "jquery.min.js", type: "text/javascript"})
#   h.script(attributes: {src: "dbdiff.js", type: "text/javascript"})
# end
# puts head.render
# <head class='lala'>
#   <link rel='stylesheet' href='diff_table.scss' type='text/css'>
#   <link rel='stylesheet' href='input.scss' type='text/css'>
#   <link rel='stylesheet' href='select.scss' type='text/css'>
#   <script src='jquery.min.js' type='text/javascript'></script>
#   <script src='dbdiff.js' type='text/javascript'></script>
# </head>

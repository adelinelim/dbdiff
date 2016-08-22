module Components
  class Form < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || options
    end

    def render
      "<form#{render_attributes}>#{@content}#{render_children}</form>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end

    def render_children
      @children.map do |child|
        child.render
      end.join("\n")
    end
  end
end

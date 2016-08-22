module Components
  class Head < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || {}
    end

    def render
      "<head#{render_attributes}>#{@content}#{render_children}</head>"
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

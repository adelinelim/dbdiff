module Components
  class Table < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || options.except(:content)
    end

    def render
      test = render_children
      if test == ""
        binding.pry
      end
      "<table#{render_attributes}>#{@content}#{test}</table>"
    end

    private

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

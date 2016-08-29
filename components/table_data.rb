module Components
  class TableData < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || options.except(:content)
    end

    def render
      "<td#{render_attributes}>#{@content}</td>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

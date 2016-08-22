module Components
  class Tag < BaseComponent
    def initialize(options = {})
      super
      @tag = options[:tag]
      @attributes = options[:attributes] || {}
      @content = options[:content] || ""
    end

    def render
      "<#{@tag}#{render_attributes}>#{@content}</#{@tag}>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

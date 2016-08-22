module Components
  class Script < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || options
    end

    def render
      "<script#{render_attributes}>#{@content}</script>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

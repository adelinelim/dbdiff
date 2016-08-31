module Components
  class TableHeader < BaseComponent
    def initialize(options = {})
      super
      @content = options[:content] || ""
      @attributes = options[:attributes] || options.except(:content)
    end

    def render
      if @content == ""
        binding.pry
      end
      "<thead><tr><th#{render_attributes}>#{@content}</th></tr></thead>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

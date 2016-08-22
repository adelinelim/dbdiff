module Components
  class Text < BaseComponent
    def initialize(options = {})
      super
      @attributes = options
    end

    def render
      "<input#{render_attributes}>"
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

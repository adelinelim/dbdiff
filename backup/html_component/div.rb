module HtmlComponent
  class Div
    def initialize(attributes)
      @attributes = attributes
    end

    def perform
      attributes = @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join

      tag = "<div #{attributes}>"
      # binding.pry
      # tag += yield
      tag + "</div>"
    end
  end
end

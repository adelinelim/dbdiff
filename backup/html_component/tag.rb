module HtmlComponent
  class Tag
    def initialize(values)
      @tag = values[:tag]
      @attributes = values[:attributes]
      @content = values[:content]
    end

    def perform
      attribute = ""
      if @attributes.present?
        attribute = @attributes.map do |k, v|
          " #{k}='#{v}'"
        end.join
      end

      result = "<#{@tag}#{attribute}>"
      result += "#{@content}"
      result + "</#{@tag}>"
    end
  end
end

module HtmlComponent
  class ComponentTag
    def initialize(attributes)
      @attributes = attributes
    end

    def tag_name
      raise "need to implement this"
    end

    def perform
      tag = "<#{tag_name}"

      tag += @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join

      tag + closing_tag
    end

    def closing_tag
      "></#{tag_name}>"
    end
  end
end

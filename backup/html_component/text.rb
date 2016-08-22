module HtmlComponent
  class Text < ComponentTag
    def tag_name
      "input"
    end

    def closing_tag
      ">"
    end
  end
end

# class Customize
#   def initialize(content)
#     @content = content
#   end
#
#   def perform
#     @content
#   end
# end

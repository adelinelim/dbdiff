module HtmlComponent
  class Link < ComponentTag
    def tag_name
      "link"
    end

    def closing_tag
      "/>"
    end
  end
end

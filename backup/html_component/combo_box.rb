module HtmlComponent
  class ComboBox
    def initialize(attributes)
      @attributes = attributes
    end

    def perform
      tag = "<select"
      @attributes[:select].each do |k, v|
        tag += " #{k}='#{v}'"
      end
      tag += ">"

      standarized_options = option_canonicalizer(@attributes[:option])

      string_options = standarized_options.map do |k|
        "<option value='#{k[0]}'>#{k[1]}</option>"
      end.join

      tag + string_options + "</select>"
    end

    private

    def option_canonicalizer(raw_options)
      raw_options.map do |option|
        if option.is_a? String
          # to convert string to array form
          [option, option]
        else
          option
        end
      end
    end
  end
end

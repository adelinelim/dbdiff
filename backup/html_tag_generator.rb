class HtmlTagGenerator
  FORM_COMPONENT = "HtmlComponent"
  CONTENT_COMPONENT_LIST = [
    :text,
    :combo_box,
    :tag,
    :link,
    :script
  ]

  def initialize(options = {})
    @options = options
    @commands = []
    yield(self)
  end

  CONTENT_COMPONENT_LIST.each do |component|
    define_method :"#{component}" do |attributes|
      attributes = {attributes: attributes}
      @commands << attributes.merge(type: component)
    end
  end

  # COMPONENT_LIST.each do |component|
  #   define_method :"#{component}" do |*args, &block|
  #     klass = component.to_s.camelize.constantize
  #     # add(klass.new(*args, &block))
  #   end
  # end

  def div(attributes)
    attributes = {attributes: attributes}
    @commands << attributes.merge(type: :div)
    yield(self)
  end

  def customize(attributes)
    yield
  end

  def render
    generate_tag do |f|
      @commands.map do |c|
        generate_class(c[:type]).new(c[:attributes]).perform
      end.join
    end
  end

  private

  def generate_tag
    attrs = @options[:attributes] || {}
    attributes = attrs.map do |k, v|
      " #{k}='#{v}'"
    end.join

    tag_name = @options[:type]

    tag = "<#{tag_name} #{attributes}>"
    tag += yield
    tag += "</#{tag_name}>"
  end

  def generate_class(type)
    get_form_name(type).constantize
  end

  def get_form_name(type)
    "#{FORM_COMPONENT}::#{type.to_s.camelize}"
  end
end

module Components
  class Customize < BaseComponent
    def initialize(options)
      @content = options
    end

    def render
      @content
    end
  end
end

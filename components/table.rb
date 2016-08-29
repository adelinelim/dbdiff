module Components
  class Table < BaseComponent
    def initialize(options = {})
      super
      @thead = options[:thead] || ""
      @tbody = options[:tbody] || ""
      @attributes = options[:attributes] || get_attributes(options)
    end

    def render
      %[
        <table#{render_attributes}>
          <thead>
            <tr>
            #{@thead}
            </tr>
          </thead>

          <tbody>
            #{@tbody}
          </tbody>
        </table>
      ]
    end

    private

    def get_attributes(options)
      options.except(:tbody).except(:thead)
    end

    def render_attributes
      @attributes.map do |k, v|
        " #{k}='#{v}'"
      end.join
    end
  end
end

module Services
  class ParamsGenerator
    def initialize(params)
      @params = params
    end

    def generate_diff_params
      Hashie::Mash.new({
        cid: @params[:cid],
        encoded_params: encoded_params
      })
    end

    private

    def encoded_params
      @params.map do |k,v|
        "#{encode(k)}=#{encode(v)}"
      end.join('&')
    end

    def encode(value)
      URI::encode(value)
    end
  end
end

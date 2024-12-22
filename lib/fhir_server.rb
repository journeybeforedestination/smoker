class FhirServer
  def initialize(iss)
    @url = iss
  end

  def fetch_config
    conn = Faraday.new(url: File.join(@url, ".well-known/smart-configuration")) do |builder|
      builder.request :json
      builder.response :json
      builder.response :raise_error
      builder.response :logger
    end

    # todo handle errors from remote server
    conn.get
  end
end

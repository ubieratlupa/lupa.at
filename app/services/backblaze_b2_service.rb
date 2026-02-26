class BackblazeB2Service

  def self.auth_token
    Rails.cache.fetch("B2_AUTH_TOKEN", expires_in: 12.hours) do
      uri = URI::HTTPS.build(
        host: ENV.fetch("B2_HOST"),
        path: "/b2api/v4/b2_authorize_account"
      )
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(
        ENV.fetch("B2_USER"),
        ENV.fetch("B2_PASSWORD")
      )
      response = http.request(request)
      raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body).fetch("authorizationToken")
    end
  end
  
  def 
end

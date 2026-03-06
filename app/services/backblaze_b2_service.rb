class BackblazeB2Service

  def self.authorisation
    Rails.cache.fetch("BackblazeB2Service.Authorisation", expires_in: 12.hours) do
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
      JSON.parse(response.body)
    end
  end
  
  
  def self.download_url(bucket, path)
    auth = self.authorisation
    uri = URI::HTTPS.build(
      host: ENV.fetch("B2_HOST"),
      path: "/b2api/v4/b2_get_download_authorization"
    )
    arguments = {
      bucketId: bucket,
      fileNamePrefix: path,
      validDurationInSeconds: 3600
    }
    headers = {
      Authorisation: auth['authorizationToken']
    }
    response = Net::HTTP.post(uri, arguments.to_json, headers)
    raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    download_token = JSON.parse(response.body).fetch("authorizationToken")
    base_url = auth['apiInfo']['storageApi']['downloadUrl']
    "#{base_url}/file/#{bucket}/#{path}?Authorisation=#{download_token}"
  end
end

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
      body = JSON.parse(response.body)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Backblaze Error Code #{body['code']}: #{body['message']}")
        raise "HTTP #{response.code}" 
      end
      body
    end
  end
  
  def self.bucketId(bucketName)
    Rails.cache.fetch("BackblazeB2Service.BucketID.#{bucketName}", expires_in: 12.hours) do
      auth = self.authorisation
      uri = URI::HTTPS.build(
        host: ENV.fetch("B2_HOST"),
        path: "/b2api/v4/b2_list_buckets"
      )
      arguments = {
        accountId: auth.fetch("accountId"),
        bucketName: bucketName
      }
      headers = {
        Authorization: auth.fetch('authorizationToken')
      }
      response = Net::HTTP.post(uri, arguments.to_json, headers)
      body = JSON.parse(response.body)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Backblaze Error Code #{body['code']}: #{body['message']}")
        raise "HTTP #{response.code}" 
      end
      body["buckets"].first["bucketId"]
    end
  end
  
  def self.download_url(bucketName, path)
    auth = self.authorisation
    uri = URI::HTTPS.build(
      host: ENV.fetch("B2_HOST"),
      path: "/b2api/v4/b2_get_download_authorization"
    )
    arguments = {
      bucketId: self.bucketId(bucketName),
      fileNamePrefix: path,
      validDurationInSeconds: 3600,
      b2ContentDisposition: "attachment"
    }
    headers = {
      Authorization: auth.fetch('authorizationToken')
    }
    response = Net::HTTP.post(uri, arguments.to_json, headers)
    body = JSON.parse(response.body)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Backblaze Error Code #{body['code']}: #{body['message']}")
      raise "HTTP #{response.code}" 
    end
    download_token = body.fetch("authorizationToken")
    base_url = auth['apiInfo']['storageApi']['downloadUrl']
    "#{base_url}/file/#{bucketName}/#{path}?Authorization=#{download_token}&b2ContentDisposition=attachment"
  end
end

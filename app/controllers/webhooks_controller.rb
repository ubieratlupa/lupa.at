class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token

  def process_backblaze_notification
    signature_header = request.headers["X-Bz-Event-Notification-Signature"]
    raw_body = request.raw_post

    raise "Missing signature" if signature_header.blank?

    version, their_signature = signature_header.strip.split("=", 2)
    raise "Unsupported signature version" unless version == "v1"

    secret = ENV.fetch("BACKBLAZE_WEBHOOK_SECRET")
    expected_signature = OpenSSL::HMAC.hexdigest("sha256", secret, raw_body)

    unless ActiveSupport::SecurityUtils.secure_compare(expected_signature, their_signature)
      raise "Invalid signature"
    end

    data = JSON.parse(raw_body)
    events = data['events']
    raise ArgumentError, 'Missing events' unless events.is_a?(Array)

    ActiveRecord::Base.transaction do
      events.each do |event|
        event_id = event['eventId']
        bucket_name = event['bucketName']
        object_name = event['objectName']
        event_type = event['eventType']
        timestamp = Time.at(event['eventTimestamp'] / 1000.0)

        sql = ActiveRecord::Base.sanitize_sql([
          "INSERT INTO automation.backblaze_notifications (event_id, bucket_name, object_name, event_type, timestamp, payload) VALUES (?, ?, ?, ?, ?, ?)",
          event_id,
          bucket_name,
          object_name,
          event_type,
          timestamp,
          event.to_json
        ])

        ActiveRecord::Base.connection.execute(sql)
      end
    end

    head :ok
  end
  
end

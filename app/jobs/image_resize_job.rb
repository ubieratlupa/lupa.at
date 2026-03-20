require "open3"
require 'shellwords'

class ImageResizeJob < ApplicationJob
    
  def perform(photo_id)
    photo = Photo.find(photo_id)
    
    download_url = photo.download_url
    filename = photo.filename
    
    stdout, stderr, status = Open3.capture3("curl -L #{Shellwords.escape(download_url)} | gm convert -size 2000x2000 - -resize '2000x2000>' +profile '*' /var/www/upload/img/#{Shellwords.escape(filename)}")

    Rails.logger.info "Image Resize Command Output: #{stdout}" unless stdout.empty?

    unless stderr.empty?
      Rails.logger.error "Image Resize Command Error: #{stderr}"
    end

    unless status.success?
      Rails.logger.error "Image Resize Command failed with exit code #{status.exitstatus}"
      raise "Image Resize failed for #{photo.basename}"
    end
    
  end
  
end

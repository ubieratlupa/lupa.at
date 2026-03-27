require "open3"
require 'shellwords'

class ImageResizeJob < ApplicationJob
    
  def perform(photo_id)
    photo = Photo.unscoped.find(photo_id)
    
    download_url = photo.download_url
    filename = photo.basename + '.jpg'
    
    convert_command = "curl --no-progress-meter -L #{Shellwords.escape(download_url)} | gm convert - -background white -flatten -resize '2000x2000>' +profile '*' /var/www/upload/img/#{Shellwords.escape(filename)}"
    stdout, stderr, status = Open3.capture3(convert_command)

    Rails.logger.info "Image Resize Command Output: #{stdout}" unless stdout.empty?

    unless status.success?
      Rails.logger.error "Image Resize Command Error: #{stderr}"
      Rails.logger.error "Image Resize Command failed with exit code #{status.exitstatus}"
      raise "Image Resize failed for #{photo.basename}\nShell Command: #{convert_command}\nExit Status #{status.exitstatus}\n#{stderr}"
    end
    
    width = `gm identify -format '%w' /var/www/upload/img/#{Shellwords.escape(filename)}`.to_i
    height = `gm identify -format '%h' /var/www/upload/img/#{Shellwords.escape(filename)}`.to_i
    photo.update(width: width, height: height, filename: filename)
    
  end
  
end

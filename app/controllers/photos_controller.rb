class PhotosController < ApplicationController
  def download
    photo = Photo.find_by(download_link: "https://lupa.at/download/#{params[:auth_code]}/#{params[:filename]}.#{params[:ext]}")
    components = photo.filename_for_download.match(/\Abackblaze:([^\/]+)\/(.+)\z/)
    bucket = components[1]
    path = components[2]
    redirect_to BackblazeB2Service.download_url(bucket, path)
  end
end
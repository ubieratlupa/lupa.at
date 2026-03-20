class PhotosController < ApplicationController
  def download
    photo = Photo.find_by(download_link: "https://lupa.at/download/#{params[:auth_code]}/#{params[:filename]}.#{params[:ext]}")
    redirect_to photo.download_url
  end
end
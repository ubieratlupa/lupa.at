class MonumentsController < ApplicationController

  def show
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord)
    @title = @monument.title
  end

end

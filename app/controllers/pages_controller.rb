class PagesController < ApplicationController

  def about
  	@num_monuments = Monument.all.size
  	@num_photos = Photo.all.size
  end

end

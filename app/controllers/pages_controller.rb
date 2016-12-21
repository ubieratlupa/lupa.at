class PagesController < ApplicationController
  
  def show
    @other_pages = Page.order(:ord)
    @current_page = Page.find(params[:id])
    @title = @current_page.title
    @text = @current_page.text
    @text.gsub! "NUMBER_OF_PHOTOS", Photo.all.size.to_s
    @text.gsub! "NUMBER_OF_MONUMENTS", Monument.all.size.to_s
  end

end

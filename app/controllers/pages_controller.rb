class PagesController < ApplicationController
  
  def show
    @other_pages = Page.where('category = ?', 'about').order(:ord)
    @current_page = Page.find(params[:id])
  end

end

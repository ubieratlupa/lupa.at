class PagesController < ApplicationController
  
  def index
    @other_pages = Page.where('category = ?', 'about').order(:ord)
    @current_page = Page.find('index')
    @header_page = Page.find('index-header')
    
    @photos = 
      Photo
        .joins("JOIN (select round(random() * (select max(id) from photos)) as id from generate_series(1,36)) as ids
on photos.id = ids.id")
        .joins(:monument)
        .limit(18)
    
    
    @new_monuments_date = Monument.recent_monuments_month
    @new_monuments = Monument.recent_monuments(@new_monuments_date).limit(5)
    @new_monuments_count = @new_monuments.count
    @new_monuments_source = { recent: @new_monuments_date }
  end
  
  def show
    @other_pages = Page.where('category = ?', 'about').order(:ord)
    @current_page = Page.find(params[:id])
  end

end

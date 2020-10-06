class PagesController < ApplicationController
  
  def index
    @other_pages = Page.where('category = ?', 'about').order(:ord)
    @current_page = Page.find('index')
    
    @photos = 
      Photo
        .joins("JOIN (select round(random() * (select max(id) from photos)) as id from generate_series(1,36)) as ids
on photos.id = ids.id")
        .joins(:monument)
        .limit(18)
    
    
    @new_monuments_date = Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = ?)", @new_monuments_date)
    @new_monuments_count = @new_monuments.count
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.limit(5)
    @new_monuments = @new_monuments
  end
  
  def show
    @other_pages = Page.where('category = ?', 'about').order(:ord)
    @current_page = Page.find(params[:id])
  end

end

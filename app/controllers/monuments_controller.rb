class MonumentsController < ApplicationController

  def show
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord, :id)
    @title = @monument.title
  end
  
  def qr
    @monument = Monument.find(params[:id])
    @title = @monument.title
    render layout: "print"
  end

  def index
    @query = Query.find(1)
    @new_monuments_date = Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = ?)", @new_monuments_date)
    @new_monuments_count = @new_monuments.count
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.limit(6)
    @new_monuments = @new_monuments
    @index_page = Page.find('index')
  end
  
  def recent
    @new_monuments_date = Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = ?)", @new_monuments_date)
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.page(params[:page]).per(50)
  end
  
  def photos
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord, :id).page(params[:page]).per(1)
    @photo = @photos.first
  end
  
end

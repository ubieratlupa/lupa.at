class MonumentsController < ApplicationController

  def show
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord)
    @title = @monument.title
  end
  
  def qr
    @monument = Monument.find(params[:id])
    @title = @monument.title
    render layout: "print"
  end

  def index
    @query = Query.find(1)
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = (select date_trunc('month',max(created)) latest_month from photos where monument_id in (select id from monuments where visible)))")
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.page().per(6)
    @index_page = Page.find('index')
  end
  
  def recent
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = (select date_trunc('month',max(created)) latest_month from photos where monument_id in (select id from monuments where visible)))")
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.page(params[:page]).per(50)
  end
  
end

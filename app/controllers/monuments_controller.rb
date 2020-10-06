class MonumentsController < ApplicationController

  def show
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord, :id)
    @title = @monument.id.to_s + ' ' + @monument.title
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
    @new_monuments = @new_monuments.limit(5)
    @new_monuments = @new_monuments
    @index_page = Page.find('index')
    @query_help_page = Page.find('query-help')
  end
  
  def search
    @query = Query.find(1)
    @query_help_page = Page.find('query-help')
  end
  
  def recent
    @new_monuments_date = Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
    @new_monuments = Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) = ?)", @new_monuments_date)
    @new_monuments = @new_monuments.order("id desc")
    @new_monuments = @new_monuments.page(params[:page]).per(50)
  end
  
  def photos
    if params[:page].nil? 
      redirect_to page: 1
      return
    end
    @monument = Monument.find(params[:id])
    @all_photos = @monument.photos.order(:ord, :id).each_with_index.map do |photo, idx|
      { 
        src: 'http://lupa.at/img/' + photo.filename,
        number: photo.filename.sub(/\.jpe?g$/i, ''),
        caption: photo.caption,
        comment: photo.comment || "",
        url: url_for( controller: 'monuments', action: 'photos', id: @monument.id, page: idx+1),
        publication_permission_required: photo.copyright ? photo.copyright.publication_permission_required : true
      }
    end
    @curr_photo_index = params[:page].to_i - 1
    @title = @monument.id.to_s + ' ' + @monument.title + " (Bilder)"
    render layout: 'photo'
  end
  
end

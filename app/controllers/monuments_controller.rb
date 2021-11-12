class MonumentsController < ApplicationController

  def show
    m_id = params[:id].to_i
    @monument = Monument.find(params[:id])
    @photos = @monument.photos.order(:ord, :id)
    find_next_prev(m_id)
    @title = @monument.id.to_s + ' ' + @monument.title
  end
  
  def find_next_prev(m_id)
    q_id = params[:query].to_i
    if q_id > 0
      @source = {query: q_id}
      ids = Rails.cache.fetch("query/#{q_id}/matching_ids", expires_in: 30.minutes) do
        Query.find(q_id).matching_ids
      end
    end
    if ids
      midx = ids.index(m_id)
      if midx
        @monument_index_in_query = midx
        @query_monuments_count = ids.length
        if midx > 0
          @prev_monument_id = ids[midx-1]
        end
        if midx < ids.length - 1
          @next_monument_id = ids[midx+1]
        end
      end
    end
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
        src: 'http://lupa.at/img/' + ERB::Util.url_encode(photo.filename),
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

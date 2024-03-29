class PublicationsController < ApplicationController
  
  def index
    @publications = Publication.find_by_sql("SELECT * FROM publications ORDER BY year DESC, created DESC")
    @page = Page.find('publications-index')
  end
  
  def show
    @publication = Publication.find(params[:id])
    @monuments = @publication.monuments.order(:id)
    @display_mode = params[:mode] || "list"
    if @display_mode=="photos"
     @monuments = @monuments.where('EXISTS (select * from photos where photos.monument_id = Monuments.id)')
     @monuments = @monuments.page(params[:page]).per(48)
    elsif @display_mode == "map"
     @monuments = @monuments.where('finding_place_id in (select id from vocabulary.places where long is not null)')
     place_ids = @monuments.map{ |m| m.finding_place_id }.uniq
     @places = Place.where("id in (?)", place_ids)
     @mid_long = 0
     @mid_lat = 0
     n = 0
     @places.each do |p|
       @mid_long += p.long
       @mid_lat += p.lat
       n += 1
     end
     if n > 0
       @mid_long /= n
       @mid_lat /= n
     else
       @mid_lat = 47
       @mid_long = 13.975
     end
    elsif @display_mode == "place"
     @monuments = @monuments.where(finding_place: params[:place])
     @place = Place.find(params[:place])
    else
     @monuments = @monuments.page(params[:page]).per(50)
    end
  end
  
end

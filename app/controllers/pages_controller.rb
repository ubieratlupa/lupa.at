class PagesController < ApplicationController
  
  def index
    @header_page = Page.find('index-header')

    @places = Place
          .all()
          .joins('RIGHT JOIN monuments ON monuments.finding_place_id=places.id')
          .group('places.id')
          .where('long IS NOT NULL')
          .order(:id)
          .select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS monuments_count')
    @conservation_places = Place
          .all()
          .joins('RIGHT JOIN monuments ON monuments.conservation_place_id=places.id')
          .group('places.id')
          .where('long IS NOT NULL')
          .order(:id)
          .select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS monuments_count')
    @museum_places = Place
          .all()
          .joins('RIGHT JOIN museums ON museums.place_id=places.id')
          .group('places.id')
          .where('long IS NOT NULL')
          .order(:id)
          .select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS museums_count')    

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

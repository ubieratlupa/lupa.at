class PlacesController < ApplicationController

  def index
    @places = Place
    			.all()
    			.joins('LEFT JOIN monuments ON monuments.finding_place_id=places.id')
    			.group('places.id')
    			.where('long IS NOT NULL')
    			.order(:id)
    			.select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS monuments_count')
  end

  def show
    @place = Place.find(params[:id])
    @monuments_found = Monument.found_in(@place).page(1).per(6)
    @monuments_conserved = Monument.conserved_in(@place).page(1).per(6)
    @children = @place.children
  end

  def show_finding
    @place = Place.find(params[:id])
    @monuments_found = Monument.found_in(@place).page(params[:page]).per(50)
  end

  def show_conservation
    @place = Place.find(params[:id])
    @monuments_conserved = Monument.conserved_in(@place).page(params[:page]).per(50)
  end

  def map_finding_places
    @places = Place
    			.all()
    			.joins('RIGHT JOIN monuments ON monuments.finding_place_id=places.id')
    			.group('places.id')
    			.where('long IS NOT NULL')
    			.order(:id)
    			.select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS monuments_count')
  end

end

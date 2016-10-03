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

  def map_finding_places
    @places = Place
    			.all()
    			.joins('LEFT JOIN monuments ON monuments.finding_place_id=places.id')
    			.group('places.id')
    			.where('long IS NOT NULL')
    			.order(:id)
    			.select(:id, :name, :full_name, :lat, :long, 'COUNT(*) AS monuments_count')
  end

end

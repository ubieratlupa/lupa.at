module MonumentHelper
  def monument_short_path(monument)
    { controller: "monuments", action: "show", id: monument }
  end
  
  def link_to_monument(monument) 
    link_to monument.title, monument_short_path(monument)
  end
  
  def finding_place_path(place)
    url_for({ controller: "places", action: "show_finding", id: place }) if place
  end
  
  def link_to_finding_place(place)
    link_to place.name, finding_place_path(place) if place
  end
end

module MonumentHelper
  def monument_short_path(monument, query=nil)
    url_for controller: "monuments", action: "show", id: monument, query: query
  end
  
  def link_to_monument(monument) 
    link_to "#{monument.id} #{monument.title}", monument_short_path(monument)
  end
  
  def canonical_url_for_monument(monument)
    "http://lupa.at/#{monument.id}"
  end
    
  def link_to_place(place)
    link_to place.name, place if place
  end
  
  def link_to_finding_place(place)
    link to place.name, {controller: "places", action: "show_finding", id: place} if place
  end
  
  def link_to_conservation_place(place)
    link to place.name, {controller: "places", action: "show_conservation", id: place} if place
  end
  
end

module MonumentHelper
  def monument_short_path(monument)
    url_for controller: "monuments", action: "show", id: monument
  end
  
  def link_to_monument(monument) 
    link_to monument.title, monument_short_path(monument)
  end
    
  def link_to_place(place)
    link_to place.name, place if place
  end
  
end

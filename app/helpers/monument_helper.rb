module MonumentHelper
  def monument_short_path(monument)
    { controller: "monuments", action: "show", id: monument }
  end
  
  def link_to_monument(monument) 
    link_to monument.title, monument_short_path(monument)
  end
end

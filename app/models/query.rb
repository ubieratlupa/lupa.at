class Query < ActiveRecord::Base

  def matches
    matches = Monument.all
    
    if keywords
      for keyword in keywords.split(/\s+/)
        matches = matches.where("concat_ws(' ', title, comment, catalog_text, object_type, monument_type, iconography, inscription_type) ILIKE ?", "%#{keyword}%")
      end
    end
    
    if inscription
      for term in inscription.split(/\s+/)
        matches = matches.where("regexp_replace(regexp_replace(inscription,'[][()?!{}/\\s-]','','g'), '<([^=>]+)(=[^>]+)?>', '\1', 'g') ILIKE :term OR inscription ILIKE :term", {term: "%#{term}%"})
      end
    end
    
    if id_ranges
      range_formats = []
      range_arguments = []
      for range in id_ranges.scan(/(\d+)\s*(?:-\s*(\d+))?/)
        if range[1]
          range_formats.append "id BETWEEN ? AND ?"
          range_arguments.append range[0]
          range_arguments.append range[1]
        else
          range_formats.append "id = ?"
          range_arguments.append range[0]
        end
      end
      condition = range_arguments
      condition.prepend range_formats.join(" OR ")
      matches = matches.where(condition)
    end
    
    if literature
      for term in literature.split(/\s+/)
        matches = matches.where("concat_ws(' ',literature,literature_online) ILIKE ?", "%#{term}%")
      end
    end
    
    if museum
      for term in museum.split(/\s+/)
        matches = matches.joins(museum: :place).where("museums.name || ' ' || places.name ILIKE ?", "%#{term}%")
      end
    end
    
    if conservation_place
      matches = matches.where("conservation_place_id in (with recursive place_ids as (select id from vocabulary.places where regexp_split_to_array(lower(name), '\\W+') @> regexp_split_to_array(lower(?), '\\W+') union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", conservation_place)
    end
    
    if finding_place
      matches = matches.where("finding_place_id in (with recursive place_ids as (select id from vocabulary.places where regexp_split_to_array(lower(name), '\\W+') @> regexp_split_to_array(lower(?), '\\W+') union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", finding_place)
    end
    
    return matches
  end
  
  def self.allowed_search_parameters
    return :keywords, :inscription, :id_ranges, :museum, :finding_place, :conservation_place, :literature
  end
end
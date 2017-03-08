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
        matches = matches.where("regexp_replace(regexp_replace(inscription,'[][()?!{}/\\s-]','','g'), '<([^=>]+)(=[^>]+)?>', '\\1', 'g') ILIKE :term OR inscription ILIKE :term", {term: "%#{term}%"})
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
  
  def inscription_excerpt(monument)
    return nil unless inscription
    original = monument.inscription
    downcase = original.downcase
    offsets = []
    inscription.downcase.split(/\s+/).each_with_index do |term, i|
      regex = ""
      term.split("").each_with_index do |c ,i|
        regex += "(\\<|(=[^\\>]+)?\\>|[\\]\\[()?!{}/\\s-])*" if i > 0
        regex += Regexp.escape(c)
      end
      i = 0
      while match = downcase.match(regex, i)
        offsets.push(match.offset(0))
        i = match.end(0)
      end
    end 
    return nil unless offsets.count > 0
    offsets.sort! { |a, b| a[0] - b[0] }
    offsets.each_with_index { |m, i| puts "#{i}: #{m}" }
    i = 0
    while i < offsets.count - 1
      if offsets[i][1]>offsets[i+1][0]
        offsets[i,2] = [[offsets[i][0], [offsets[i][1],offsets[i+1][1]].max]]
      else
        i += 1
      end
    end
    offsets.each_with_index { |m, i| puts "#{i}: #{m}" }
    limit = 150
    len = (limit - inscription.length) / (offsets.count * 2)
    len = 8 unless len > 8
    extract = "".html_safe
    x = 0
    for i in 0 ... offsets.count
      a = offsets[i][0] - len
      a = x unless a > x
      extract += ERB::Util.html_escape("…") if a > x
      b = offsets[i][1] + len
      b = original.length unless b < original.length
      b = offsets[i+1][0] if i+1 < offsets.count && b > offsets[i+1][0]
      extract += ERB::Util.html_escape(original[a...offsets[i][0]])
      extract += "<b>".html_safe
      extract += ERB::Util.html_escape(original[offsets[i][0]...offsets[i][1]])
      extract += "</b>".html_safe 
      extract += ERB::Util.html_escape(original[offsets[i][1]...b])
      x = b
      break if extract.length > limit
    end
    extract += ERB::Util.html_escape("…") if x < original.length
    extract
  end
  
  def literature_excerpt(monument)
    simple_excerpt(monument.literature, literature)
  end
  
  def iconography_excerpt(monument)
    simple_excerpt(monument.iconography, keywords)
  end
  
  def simple_excerpt(original, search)
    return nil unless search
    return nil unless original
    downcase = original.downcase
    offsets = []
    search.downcase.split(/\s+/).each_with_index do |term, i|
      regex = Regexp.escape(term)
      i = 0
      while match = downcase.match(regex, i)
        offsets.push(match.offset(0))
        i = match.end(0)
      end
    end 
    return nil unless offsets.count > 0
    offsets.sort! { |a, b| a[0] - b[0] }
    offsets.each_with_index { |m, i| puts "#{i}: #{m}" }
    i = 0
    while i < offsets.count - 1
      if offsets[i][1]>offsets[i+1][0]
        offsets[i,2] = [[offsets[i][0], [offsets[i][1],offsets[i+1][1]].max]]
      else
        i += 1
      end
    end
    offsets.each_with_index { |m, i| puts "#{i}: #{m}" }
    limit = 150
    len = (limit - search.length) / (offsets.count * 2)
    len = 8 unless len > 8
    extract = "".html_safe
    x = 0
    for i in 0 ... offsets.count
      a = offsets[i][0] - len
      a = x unless a > x
      extract += ERB::Util.html_escape("…") if a > x
      b = offsets[i][1] + len
      b = original.length unless b < original.length
      b = offsets[i+1][0] if i+1 < offsets.count && b > offsets[i+1][0]
      extract += ERB::Util.html_escape(original[a...offsets[i][0]])
      extract += "<b>".html_safe
      extract += ERB::Util.html_escape(original[offsets[i][0]...offsets[i][1]])
      extract += "</b>".html_safe 
      extract += ERB::Util.html_escape(original[offsets[i][1]...b])
      x = b
      break if extract.length > limit
    end
    extract += ERB::Util.html_escape("…") if x < original.length
    extract
  end
  
end
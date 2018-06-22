class Query < ActiveRecord::Base
  belongs_to :finding_place, class_name: "Place", optional: true
  belongs_to :conservation_place, class_name: "Place", optional: true
  belongs_to :ancient_finding_place, class_name: "AncientPlace", optional: true

  def matches
    matches = Monument.all
    
    if keywords
      for keyword in keywords.split(/\s+/)
        matches = matches.where("concat_ws(' ', title, comment, catalog_text, object_type, monument_type, iconography, inscription_type) ILIKE ?", "%#{keyword}%")
      end
    end
    
    if fulltext
      for word in fulltext.split(/\s+/)
        matches = matches.where("concat_ws(' ', title, catalog_text, comment, object_type, monument_type, finding_place_comment, finding_comment, conservation_place_comment, conservation_comment, conservation_state, museum_inventory_number, iconography, inscription_type, regexp_replace(regexp_replace(concat_ws(' ',inscription, inscription_name_donor, inscription_function, inscription_formula),'[][()?!{}/\\s-]','','g'), '<([^=>]+)(=[^>]+)?>', '\\1', 'g'), inscription_comment, inscription_variants, inscription_translation, inscription_name_donor, inscription_function, inscription_formula, dating_phase, dating_comment, literature, literature_online, material, material_comment, material_local_name, material_provenance) ILIKE :word", {word: "%#{word}%"})
      end
    end
    
    if inscription
      for term in inscription.split(/\s+/)
        matches = matches.where("regexp_replace(regexp_replace(concat_ws(' ',inscription, inscription_name_donor, inscription_function, inscription_formula),'[][()?!{}/\\s-]','','g'), '<([^=>]+)(=[^>]+)?>', '\\1', 'g') ILIKE :term OR concat_ws(' ', inscription, inscription_name_donor, inscription_function, inscription_formula, inscription_comment, inscription_type) ILIKE :term", {term: "%#{term}%"})
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
        matches = matches.where("concat_ws(' ',literature,literature_online) ~* ('\\m0*' || regexp_quote(?) || '\\M')", term)
      end
    end
    
    if museum
      for term in museum.split(/\s+/)
        matches = matches.joins(museum: :place).where("concat_ws(' ', museums.name, places.name, museum_inventory_number) ILIKE ?", "%#{term}%")
      end
    end
    
    # legacy search
    if conservation_place_legacy
        matches = matches.where("conservation_place_id in (with recursive place_ids as (select id from vocabulary.places where regexp_split_to_array(lower(name), '\\W+') @> regexp_split_to_array(lower(?), '\\W+') union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", conservation_place_legacy)
    end
    
    # legacy search
    if finding_place_legacy
        matches = matches.where("finding_place_id in (with recursive place_ids as (select id from vocabulary.places where regexp_split_to_array(lower(name), '\\W+') @> regexp_split_to_array(lower(?), '\\W+') union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", finding_place_legacy)
    end
    
    # legacy search
    if ancient_finding_place_legacy
        matches = matches.where("ancient_finding_place_id in (with recursive ancient_place_ids as (select id from vocabulary.ancient_places where regexp_split_to_array(lower(name), '\\W+') @> regexp_split_to_array(lower(?), '\\W+') union select child_ancient_places.id from vocabulary.ancient_places child_ancient_places join ancient_place_ids on ancient_place_ids.id = child_ancient_places.parent_id ) select * from ancient_place_ids)", ancient_finding_place_legacy)
    end

    if conservation_place_id
      matches = matches.where("conservation_place_id in (with recursive place_ids as (select ?::int as id union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", conservation_place_id)
    end
    
    if finding_place_id
      matches = matches.where("finding_place_id in (with recursive place_ids as (with recursive place_ids as (select ?::int as id union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids) select * from place_ids)", finding_place_id)
    end
    
    if ancient_finding_place_id
      matches = matches.where("ancient_finding_place_id in (with recursive ancient_place_ids as (select ?::int as id union select child_ancient_places.id from vocabulary.ancient_places child_ancient_places join ancient_place_ids on ancient_place_ids.id = child_ancient_places.parent_id ) select * from ancient_place_ids)", ancient_finding_place_id)
    end
    
    if photo
      for term in photo.split(/\s+/)
        matches = matches.where("id in (select distinct monument_id from photos left join vocabulary.copyrights on copyrights.id = copyright_id left join vocabulary.authors on authors.id = author_id where concat_ws(' ',copyright, copyright_detail, authors.first_name, authors.last_name, authors.institution) ilike ?)", "%#{term}%")
      end
    end
    
    if dating
      for term in dating.split(/\s+/)
        matches = matches.where("concat_ws(' ',dating_phase, dating_comment) ILIKE ?", "%#{term}%")
      end
    end
    
    if dating_from || dating_to
      matches = matches.joins("left join vocabulary.dating_phases_time_span on monuments.dating_phase = dating_phases_time_span.phase_name")
    end
    
    if dating_from
      matches = matches.where("coalesce(dating_to, dating_from, phase_to, phase_from) >= ?", dating_from)
    end
    
    if dating_to
      matches = matches.where("coalesce(dating_from, dating_to, phase_from, phase_to) <= ?", dating_to)
    end
    
    return matches
  end
  
  def self.allowed_search_parameters
    return :keywords, :inscription, :id_ranges, :museum, :finding_place_id, :conservation_place_id, :literature, :ancient_finding_place_id, :photo, :dating, :fulltext, :dating_from, :dating_to
  end
  
  def inscription_excerpt(monument)
    terms = []
    terms += inscription.split(/\s+/) if inscription
    terms += fulltext.split(/\s+/) if fulltext
    return nil unless terms.count > 0
    original = monument.inscription
    downcase = original.downcase
    offsets = []
    terms.each_with_index do |term, i|
      regex = ""
      term.downcase.split("").each_with_index do |c ,i|
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
    len = (limit) / (offsets.count * 2)
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
    terms = []
    terms += literature.split(/\s+/) if literature
    terms += fulltext.split(/\s+/) if fulltext
    simple_excerpt(monument.literature, terms, :match_word)
  end
  
  def iconography_excerpt(monument)
    terms = []
    terms += literature.split(/\s+/) if literature
    terms += keywords.split(/\s+/) if keywords
    terms += fulltext.split(/\s+/) if fulltext
    simple_excerpt(monument.iconography, terms)
  end
  
  def simple_excerpt(original, search_terms, match_word = false)
    return nil unless search_terms.count > 0
    return nil unless original
    downcase = original.downcase
    offsets = []
    search_terms.each_with_index do |term, i|
      regex = Regexp.escape(term.downcase)
      regex = '\\b0*' + regex + '\\b' if match_word
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
    len = (limit) / (offsets.count * 2)
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
  
  def dating_years
    dating_years = ""
		if dating_from == dating_to
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
		elsif dating_from && dating_to
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
			dating_years += " - "
			dating_years += dating_to.abs.to_s
			dating_years += ' n. Chr.' if dating_to > 0
			dating_years += ' v. Chr.' if dating_to < 0
		elsif dating_from
			dating_years += "nach "
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
		elsif dating_to
			dating_years += "vor "
			dating_years += dating_to.abs.to_s
			dating_years += ' n. Chr.' if dating_to > 0
			dating_years += ' v. Chr.' if dating_to < 0
		end
    return dating_years
  end
  
  
end
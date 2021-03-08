class Query < ActiveRecord::Base
  belongs_to :finding_place, class_name: "Place", optional: true
  belongs_to :conservation_place, class_name: "Place", optional: true
  belongs_to :ancient_finding_place, class_name: "AncientPlace", optional: true

  def matches
    ids = Rails.cache.fetch("query/#{id}/matching_ids", expires_in: 30.minutes) do
      matching_ids
    end
    Monument.where("id in (#{ids.join(",").presence || "0"})")
  end


  def matching_ids
   
    matches = Monument.all
    
    text_queries = []
    
    if keywords
      text_queries << { 
        fields: [
          'title',
          'comment',
          'catalog_text',
          'object_type::text',
          'monument_type::text',
          'iconography',
          'inscription_type::text'
        ],
        name: 'keywords',
        query: keywords
      }
    end
      
    if fulltext
      text_queries << { 
        fields: [
          "title",
          "catalog_text",
          "comment",
          'object_type::text',
          'monument_type::text',
          "finding_place_comment",
          "finding_comment",
          "conservation_place_comment",
          "conservation_comment",
          "conservation_state",
          "museum_inventory_number",
          "iconography",
          "inscription_type::text",
          "regexp_replace(regexp_replace(concat_ws(' ',inscription, inscription_name_donor, inscription_function, inscription_formula),'[][()?!{}/\\s-]','','g'), '<([^=>]+)(=[^>]+)?>', '\\1', 'g')",
          "inscription_comment",
          "inscription_variants",
          "inscription_translation",
          "inscription_name_donor",
          "inscription_function",
          "inscription_formula",
          "dating_phase::text",
          "dating_comment",
          "literature",
          "literature_online",
          "material::text",
          "material_comment",
          "material_local_name",
          "material_provenance"
        ],
        name: 'fulltext',
        query: fulltext
      }
    end
    
    if inscription
      text_queries << { 
        fields: [
          "regexp_replace(regexp_replace(concat_ws(' ',inscription, inscription_name_donor, inscription_function, inscription_formula),'[][()?!{}/-]','','g'), '<([^=>]+)(=[^>]+)?>', '\\1', 'g')",
          "inscription_comment",
          "inscription_type::text"
        ],
        name: 'inscription',
        query: inscription
      }
    end
       
    if dating
      text_queries << { 
        fields: [
          "dating_phase::text",
          "dating_comment",
        ],
        name: 'dating',
        query: dating
      }
    end
    
    if literature
      text_queries << { 
        fields: [
          "literature",
          "literature_online",
        ],
        name: 'literature',
        query: literature
      }
    end
   
    if museum
      text_queries << { 
        fields: [
          "museums.name",
          "places.name",
          "museum_inventory_number",
        ],
        name: 'museum',
        query: museum
      }
      matches = matches.joins(museum: :place)
    end
    
    text_matches = []
    
    for query in text_queries
      matches = matches.where("query_match(#{Monument.connection.quote(query[:query])}, #{query[:fields].join(", ")})")
      text_matches << "#{Monument.connection.quote(query[:name])}, ARRAY(SELECT query_matches(#{Monument.connection.quote(query[:query])}, #{query[:fields].join(", ")}))"
    end
    
    if photo
      matches = matches.where("id in (select distinct monument_id from photos left join vocabulary.copyrights on copyrights.id = copyright_id left join vocabulary.authors on authors.id = author_id where query_match(?, copyright, copyright_detail, authors.first_name, authors.last_name, authors.institution))", photo)
    end
    
    # matches = matches.select("monuments.id")
    # matches = matches.select("jsonb_build_object(#{text_matches.join(',\n')})")
    
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
    
    if conservation_place_id
      matches = matches.where("conservation_place_id in (with recursive place_ids as (select ?::int as id union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids)", conservation_place_id)
    end
   
    if finding_place_id
      matches = matches.where("finding_place_id in (with recursive place_ids as (with recursive place_ids as (select ?::int as id union select child_places.id from vocabulary.places child_places join place_ids on place_ids.id = child_places.parent_id ) select * from place_ids) select * from place_ids)", finding_place_id)
    end
   
    if ancient_finding_place_id
      matches = matches.where("ancient_finding_place_id in (with recursive ancient_place_ids as (select ?::int as id union select child_ancient_places.id from vocabulary.ancient_places child_ancient_places join ancient_place_ids on ancient_place_ids.id = child_ancient_places.parent_id ) select * from ancient_place_ids)", ancient_finding_place_id)
    end
      
    if dating_from || dating_to
      matches = matches.joins("left join vocabulary.dating_phases_time_span on monuments.dating_phase = dating_phases_time_span.phase_name")
    end
   
    if dating_from
      matches = matches.where("coalesce(dating_from, phase_from) >= ?", dating_from)
    end
    
    if object_type
      matches = matches.where("object_type::text like ? OR monument_type::text like ?", '%' + object_type + '%', '%' + object_type + '%')
    end
    
    if inscription_type
      matches = matches.where("inscription_type::text like ?", '%' + inscription_type + '%')
    end
   
    if dating_to
      matches = matches.where("coalesce(dating_to, phase_to) <= ?", dating_to)
    end
   
    return matches.order(:id).pluck(:id)
  end
 
  def self.allowed_search_parameters
    return :object_type, :inscription_type, :keywords, :inscription, :id_ranges, :museum, :finding_place_id, :conservation_place_id, :literature, :ancient_finding_place_id, :photo, :dating, :fulltext, :dating_from, :dating_to
  end
 
  def inscription_excerpt(monument)
    terms = []
    terms += inscription.split(/\s*;\s*/) if inscription
    terms += fulltext.split(/\s*;\s*/) if fulltext
    simple_excerpt(monument.inscription, terms, :for_inscription)
  end
 
  def literature_excerpt(monument)
    terms = []
    terms += literature.split(/\s*;\s*/) if literature
    terms += fulltext.split(/\s*;\s*/) if fulltext
    simple_excerpt(monument.literature, terms)
  end
 
  def iconography_excerpt(monument)
    terms = []
    terms += literature.split(/\s*;\s*/) if literature
    terms += keywords.split(/\s*;\s*/) if keywords
    terms += fulltext.split(/\s*;\s*/) if fulltext
    simple_excerpt(monument.iconography, terms)
  end
 
  def title_highlight(monument)
    terms = []
    terms += keywords.split(/\s*;\s*/) if keywords
    terms += fulltext.split(/\s*;\s*/) if fulltext
    simple_excerpt(monument.title, terms, false, 1000) || ERB::Util.html_escape(monument.title)
  end
 
  def simple_excerpt(original, search_terms, for_inscription = false, limit = 150)
    return nil unless search_terms.count > 0
    return nil unless original
    downcase = original.downcase
    offsets = []
    search_terms.each_with_index do |term, i|
      regex = query_to_regex(term, for_inscription)
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
  
  def query_to_regex(query, for_inscription)
    # first, replace all whitespaces with a single space
    query.gsub!(/\s+/, ' ')
    
    # now loop through each character
    # escape all characters, except spaces and * (which becomes something else)
    regex = ""
    query.split("").each do |l|
      if l == '*'
        if for_inscription
          regex += '[\S\\[\\]()?!{}/-]*'
        else
          regex += '\S*'
        end
      elsif l == ' '
        if for_inscription
          regex += '[\\W\\[\\]()?!{}/-]*\W'
        else
          regex += '\W+'
        end
      else 
        regex += "[\\[\\]()?!{}/-]*" if regex.length > 0 && for_inscription
        regex += Regexp.escape(l)
      end
    end
    
    # add word boundaries before and after
    return '\b' + regex + '\b'
  end
 
 
end
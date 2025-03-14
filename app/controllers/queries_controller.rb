class QueriesController < ApplicationController
  # allow creating queries without requiring an authenticity token
  skip_before_action :verify_authenticity_token, :only => [:create]

  def show
    @query = Query.find(params[:id])
    @query.has_3d_model = params[:has_3d_model] == "1"  # manually retrieve the has_3d_model flag from URL params
    @monuments = @query.matches.order(:id)
    
    @display_mode = params[:mode] || "list"
    if @display_mode=="photos"
      @monuments = @monuments.where('EXISTS (select * from photos where photos.monument_id = Monuments.id)')
      @monuments = @monuments.page(params[:page]).per(48)
    elsif @display_mode == "map"
      @monuments = @monuments.where('finding_place_id in (select id from vocabulary.places where long is not null)')
      place_ids = @monuments.map{ |m| m.finding_place_id }.uniq
      @places = Place.where("id in (?)", place_ids)
      @mid_long = 0
      @mid_lat = 0
      n = 0
      @places.each do |p|
        @mid_long += p.long
        @mid_lat += p.lat
        n += 1
      end
      if n > 0
        @mid_long /= n
        @mid_lat /= n
      else
      	@mid_lat = 47
      	@mid_long = 13.975
      end
    elsif @display_mode == "place"
      @monuments = @monuments.where(finding_place: params[:place])
      @place = Place.find(params[:place])
    else
      @monuments = @monuments.page(params[:page]).per(50)
    end
    
  end
  
  def edit
    @query = Query.find(params[:id])
    @query_help_page = Page.find('query-help')
  end
  
  def qr
    @query = Query.find(params[:id])
    @monuments = @query.matches.order(:id)
    render layout: "print"
  end

  def create
    p = params.require(:query).permit(Query.allowed_search_parameters)
    p.delete_if {|k,v| v.blank?}
    if p[:dating_from]
      bc = /\d\W*[vb]/i =~ p[:dating_from] # BC, vor, v. chr. ....
      p[:dating_from] = p[:dating_from].to_i
      p[:dating_from] = -p[:dating_from].abs if bc
    end
    if p[:dating_to]
      bc = /\d\W*[vb]/i =~ p[:dating_to] # BC, vor, v. chr. ....
      p[:dating_to] = p[:dating_to].to_i
      p[:dating_to] = -p[:dating_to].abs if bc
    end
    if p[:id_ranges] && p[:id_ranges].match(/^\s*\d+\s*$/) && Monument.exists?(p[:id_ranges]) && 
        (p[:has_3d_model] == "0" || File.exist?(Rails.root.join("public", "3dm", "#{p[:id_ranges]}.nxz")))   # deactivate this line if monuments of provided single ids should be diretly shown, even if the has_3d_model flag is checked although there is no 3d model
      redirect_to controller: "monuments", action: "show", id: Monument.find(p[:id_ranges])
    else
      begin
        @query = Query.create(p)
      rescue ActiveRecord::RecordNotUnique
        # this could be a random collison, because we pick record ids randomly
        # it's extremely unlikely (1e-4) if we have a million records
        # lets just try once more. probability of two consecutive failures is 1e-8
        # that should be small enough
        @query = Query.create(p)
      end
      # manually pass on the has_3d_model flag over redirect via an URL param
      redirect_to query_path(@query, has_3d_model: p[:has_3d_model])
    end
  end
  
  def completions
    if params[:field] == 'finding_place' || params[:field] == 'conservation_place'
      places = Place.where("places.name ILIKE ?", "%#{params[:term]}%")
      places = places.order(Arel.sql("places.name ILIKE ? DESC", "#{params[:term]}"), Arel.sql("places.name ILIKE ? DESC", "#{params[:term]}%"), :name).limit(100)
      places = places.left_outer_joins(:children).select('places.*, COUNT(children_places.*) AS child_count').group('places.id')
      completions = places.map { |p| { id: p.id, title: p.name, type: p.place_type, path: p.full_name.sub(/^[^,]*(,\s*|$)/,''), child_count: p.child_count } }
      render json: completions
    elsif params[:field] == 'ancient_finding_place'
      places = AncientPlace.where("ancient_places.name ILIKE ?", "%#{params[:term]}%")
      places = places.order(Arel.sql("ancient_places.name ILIKE ? DESC", "#{params[:term]}"), Arel.sql("ancient_places.name ILIKE ? DESC", "#{params[:term]}%"), :name).limit(100)
      places = places.left_outer_joins(:children).select('ancient_places.*, COUNT(children_ancient_places.*) AS child_count').group('ancient_places.id')
      completions = places.map { |p| { id: p.id, title: p.name, path: p.full_name.sub(/^[^,]*(,\s*|$)/,''), child_count: p.child_count } }
      render json: completions
    elsif params[:field] == 'dating_phase'
      matching_phases = ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.sanitize_sql([
          "SELECT phase_name, phase_from, phase_to FROM dating_phases_time_span WHERE phase_name::text ILIKE ? ORDER BY phase_name::text ILIKE ? desc, phase_from nulls first, phase_to",
          "%#{params[:term]}%",  "#{params[:term]}%"
        ])
      )
      completions = matching_phases.map do |p|
        if p['phase_from'] && p['phase_to'] 
          path = format_year(p['phase_from']) + ' bis ' + format_year(p['phase_to'])
        else
          path = ""
        end
        { 
           id: p['phase_name'],
           title: p['phase_name'],
           path: path
         }
      end
      render json: completions
    elsif params[:field] == 'object_type'
      results = ActiveRecord::Base.connection.exec_query(
        <<~'SQLQUERY'
          WITH names AS (
          	SELECT object_type::text as name, count(1) FROM monuments WHERE object_type IS NOT NULL AND object_type != '(?)' group by object_type
            UNION
            SELECT monument_type::text, count(1) FROM monuments WHERE monument_type IS NOT NULL AND monument_type != '(?)' group by monument_type)
          SELECT 
          	regexp_replace(name, '\s*\(\?\)', '') as name,
          	sum(count) as count
          FROM names
          GROUP BY
          	regexp_replace(name, '\s*\(\?\)', '')
          ORDER BY 1;
        SQLQUERY
      )
      completions = []
      results.map do |p|
        if p['name'].downcase().include? params[:term].downcase()
          completions << { 
             id: p['name'],
             title: p['name'],
             path: p['count']
           }
         end
      end
      render json: completions
    elsif params[:field] == 'inscription_type'
      results = ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.sanitize_sql([
          "SELECT inscription_type, count(1) FROM monuments WHERE inscription_type IS NOT NULL group by inscription_type order by inscription_type"
        ])
      )
      completions = []
      results.map do |p|
        if p['inscription_type'].downcase().include? params[:term].downcase()
          completions << { 
             id: p['inscription_type'],
             title: p['inscription_type'],
             path: p['count']
           }
         end
      end
      render json: completions
    end
  end
  
  def suggestions
    if params[:field] == 'finding_place' || params[:field] == 'conservation_place'
      if params[:parent_id]
        places = Place.where(parent_id: params[:parent_id])
      else
        places = Place.where(parent_id: nil)
      end
      places = places.where("places.name is not null")
      places = places.order(:name)
      places = places.left_outer_joins(:children).distinct.select('places.*, COUNT(children_places.*) AS child_count').group('places.id')
      suggestions = places.map { |p| { id: p.id, title: p.name, type: p.place_type, path: (p.full_name.sub(/^[^,]*(,\s*|$)/,'') if p.full_name), child_count: p.child_count } }
      render json: suggestions
    elsif params[:field] == 'ancient_finding_place'
      if params[:parent_id]
        places = AncientPlace.where(parent_id: params[:parent_id])
      else
        places = AncientPlace.where(parent_id: nil)
      end
      places = places.where("ancient_places.name is not null")
      places = places.order(:name)
      places = places.left_outer_joins(:children).distinct.select('ancient_places.*, COUNT(children_ancient_places.*) AS child_count').group('ancient_places.id')
      completions = places.map { |p| { id: p.id, title: p.name, path: p.full_name.sub(/^[^,]*(,\s*|$)/,''), child_count: p.child_count } }
      render json: completions
    elsif params[:field] == 'dating_phase'
      matching_phases = ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.sanitize_sql([
          "SELECT phase_name, phase_from, phase_to FROM dating_phases_time_span ORDER BY phase_from nulls first, phase_to",
          "%#{params[:term]}%",  "#{params[:term]}%"
        ])
      )
      completions = matching_phases.map do |p|
        if p['phase_from'] && p['phase_to'] 
          path = format_year(p['phase_from']) + ' bis ' + format_year(p['phase_to'])
        else
          path = ""
        end
        { 
           id: p['phase_name'],
           title: p['phase_name'],
           path: path
         }
      end
      render json: completions
    elsif params[:field] == 'object_type'
      results = ActiveRecord::Base.connection.exec_query(
        <<~'SQLQUERY'
          WITH names AS (
          	SELECT object_type::text as name, count(1) FROM monuments WHERE object_type IS NOT NULL AND object_type != '(?)' group by object_type
            UNION
            SELECT monument_type::text, count(1) FROM monuments WHERE monument_type IS NOT NULL AND monument_type != '(?)' group by monument_type)
          SELECT 
          	regexp_replace(name, '\s*\(\?\)', '') as name,
          	sum(count) as count
          FROM names
          GROUP BY
          	regexp_replace(name, '\s*\(\?\)', '')
          ORDER BY 1;
        SQLQUERY
      )
      completions = results.map do |p|
        { 
           id: p['name'],
           title: p['name'],
           path: p['count']
         }
      end
      render json: completions
    elsif params[:field] == 'inscription_type'
      results = ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.sanitize_sql([
          "SELECT inscription_type, count(1) FROM monuments WHERE inscription_type IS NOT NULL group by inscription_type order by inscription_type"
        ])
      )
      completions = results.map do |p|
        { 
           id: p['inscription_type'],
           title: p['inscription_type'],
           path: p['count']
         }
      end
      render json: completions
    end
  end
  
  def format_year(year)
    if year < 0
      year_str = (-year).to_s + ' v. Chr.'
    else
      year_str = year.to_s
    end
    return year_str
  end
end

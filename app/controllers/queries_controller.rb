class QueriesController < ApplicationController
  # allow creating queries without requiring an authenticity token
  skip_before_action :verify_authenticity_token, :only => [:create]

  def show
    @query = Query.find(params[:id])
    @monuments = @query.matches.order(:id).page(params[:page]).per(50)
  end
  
  def edit
    @query = Query.find(params[:id])
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
    if p[:id_ranges] && p[:id_ranges].match(/^\s*\d+\s*$/) && Monument.exists?(p[:id_ranges])
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
      redirect_to @query
    end
  end
  
  def completions
    if params[:field] == 'finding_place' || params[:field] == 'conservation_place'
      places = Place.where("places.name ILIKE ?", "%#{params[:term]}%")
      places = places.order(["places.name ILIKE ? DESC", "#{params[:term]}"], ["places.name ILIKE ? DESC", "#{params[:term]}%"], :name).limit(100)
      places = places.left_outer_joins(:children).select('places.*, COUNT(children_places.*) AS child_count').group('places.id')
      completions = places.map { |p| { id: p.id, title: p.name, type: p.place_type, path: p.full_name.sub(/^[^,]*(,\s*|$)/,''), child_count: p.child_count } }
      render json: completions
    elsif params[:field] == 'ancient_finding_place'
        places = AncientPlace.where("ancient_places.name ILIKE ?", "%#{params[:term]}%")
        places = places.order(["ancient_places.name ILIKE ? DESC", "#{params[:term]}"], ["ancient_places.name ILIKE ? DESC", "#{params[:term]}%"], :name).limit(100)
        places = places.left_outer_joins(:children).select('ancient_places.*, COUNT(children_ancient_places.*) AS child_count').group('ancient_places.id')
        completions = places.map { |p| { id: p.id, title: p.name, path: p.full_name.sub(/^[^,]*(,\s*|$)/,''), child_count: p.child_count } }
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
    end
  end
end

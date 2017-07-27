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
end

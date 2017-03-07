class QueriesController < ApplicationController

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
      @query = Query.create(p)
      redirect_to @query
    end
  end
end

class QueriesController < ApplicationController

  def show
    @query = Query.find(params[:id])
    @monuments = @query.matches.order(:id).page(params[:page]).per(50)
  end

  def create
    p = params.require(:query).permit(Query.allowed_search_parameters)
    p.delete_if {|k,v| v.blank?}
    @query = Query.create(p)
    redirect_to @query
  end
end

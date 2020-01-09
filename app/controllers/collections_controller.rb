class CollectionsController < ApplicationController
  
  def index
    @collections = Collection.find_by_sql("SELECT * FROM web_queries.collections_index ORDER BY place_name")
  end
  
  def show
    @collection = Collection.find(params[:id])
    @monuments = @collection.monuments.order(:id).page(params[:page]).per(50)
  end
  
end

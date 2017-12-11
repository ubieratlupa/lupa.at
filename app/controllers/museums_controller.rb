class MuseumsController < ApplicationController

  def show
    @museum = Museum.find(params[:id])
    @monuments = @museum.monuments.page(params[:page]).per(100)
  end
  
  def index
    @museums_by_country = Hash.new { |h, k| h[k]=[] }
    Museum.find_by_sql("SELECT * FROM web_queries.museums_index").each { |museum| @museums_by_country[museum.country_name].push museum }
  end

end

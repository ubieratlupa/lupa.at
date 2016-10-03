class MuseumsController < ApplicationController

  def show
    @museum = Museum.find(params[:id])
    @monuments = @museum.monuments.page(params[:page]).per(100)
  end

end

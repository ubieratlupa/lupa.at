class RegionalInfosController < ApplicationController

  def show
    @regional_info = RegionalInfo.find(params[:id])
    #@monuments = @regional_info.monuments.order(:id).page(params[:page]).per(50)
    #@monuments_found = Monument.found_in(@place).page(1).per(6)
    @monuments_conserved = @regional_info.monuments.page(params[:page]).per(50)
  end
  
end

class YearSelectController < ApplicationController
  def show
    @form = YearSelectForm.new
    selected_year = params[:year]
    case selected_year
    when "2023"
      redirect_to year_2022_path
    when "2024"
      redirect_to year_2023_path
    end
  end
end

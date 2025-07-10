class YearSelectController < ApplicationController
  def show
    @form = YearSelectForm.new
  end

  def update
    @form = YearSelectForm.new(year_select_form_params)
    if @form.valid?
      case @form.year
      when "2023"
        redirect_to year_2023_path
      when "2024"
        redirect_to year_2024_path
      else
        redirect_to year_select_path, alert: "Please select a year"
      end
    else
      render :show
    end
  end

  private

  def year_select_form_params
    params.fetch(:year_select_form, {}).permit(:year)
  end
end

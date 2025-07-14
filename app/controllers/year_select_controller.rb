class YearSelectController < ApplicationController
  def show
    @form = YearSelectForm.new
  end

  def update
    @form = YearSelectForm.new(year_select_form_params)
    if @form.valid?
      case @form.year
      when "2023"
        # TODO: replace with actual path for 2023
        redirect_to root_path
      when "2024"
        # TODO: replace with actual path for 2023
        redirect_to root_path
      else
        redirect_to year_select_path
      end
    else
      render :show, status: :bad_request
    end
  end

  private

  def year_select_form_params
    params.fetch(:year_select_form, {}).permit(:year)
  end
end

class YearSelectController < ApplicationController
  def show
    @form = YearSelectForm.new
  end

  def update
    @form = YearSelectForm.new(year_select_form_params)
    if @form.valid?
      case @form.year
      when "2023"
        session[:year_selected] = "2023"
        redirect_to edit_email_address_path
      when "2024"
        session[:year_selected] = "2024"
        redirect_to edit_email_address_path
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

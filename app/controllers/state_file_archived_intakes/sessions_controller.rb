class StateFileArchivedIntakes::SessionsController < Devise::SessionsController

  def destroy
    year_selected = session[:year_selected]
    super
    session[:year_selected] = year_selected if year_selected.present?
  end
end

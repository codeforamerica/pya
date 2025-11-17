class SessionsController < Devise::SessionsController
  def destroy
    year_selected = session[:year_selected]
    permanently_locked = session[:permanently_locked]
    super
    session[:year_selected] = year_selected if year_selected.present?
    session[:permanently_locked] = permanently_locked if permanently_locked.present?
  end
end

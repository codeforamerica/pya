class ContactPreferenceController < BaseController
  def show
    @form = YearSelectForm.new
  end
end

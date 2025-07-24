class PagesController < BaseController
  def home
  end

  def knock_out
    @intake = current_archived_intake
  end
end

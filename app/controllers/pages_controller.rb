class PagesController < BaseController
  def home
  end

  def first_page
  end

  def knock_out
    @intake = current_archived_intake
  end
end

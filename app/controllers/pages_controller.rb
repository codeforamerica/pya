class PagesController < BaseController
  def home
  end

  def knock_out
    @intake = current_state_file_archived_intake
  end
end

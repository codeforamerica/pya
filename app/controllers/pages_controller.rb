class PagesController < ApplicationController
  def home
  end

  def knock_out
    @intake = current_archived_intake
  end
end

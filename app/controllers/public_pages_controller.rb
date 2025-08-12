class PublicPagesController < BaseController
  def internal_server_error
    respond_to do |format|
      format.html { render 'public_pages/internal_server_error', status: 500 }
      format.any { head 500 }
    end
  end

  def page_not_found
    respond_to do |format|
      format.html { render 'public_pages/page_not_found', status: 404 }
      format.any { head 404 }
    end
  end
end
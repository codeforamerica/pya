require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    # get first_page_url
    assert_response :success
  end
end

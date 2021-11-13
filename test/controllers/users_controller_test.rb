require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get signup" do
    get signup_path
    assert_response :success
    assert_select "title", full_title("Sign up")
  end

  test "should get new" do
    get users_new_url
    assert_response :success
  end
  # 
  # test "should get show" do
  #   get users_show_url
  #   assert_response :success
  # end
end

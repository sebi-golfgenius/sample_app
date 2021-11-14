require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {  name: "",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div.alert'
    assert_select 'div#error_explenation'
    assert_select 'li', "Name can't be blank"
  end

  test "test valid signup" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {  name: "example",
                                          email: "email@email.com",
                                          password: "isCorrect",
                                          password_confirmation: "isCorrect" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end

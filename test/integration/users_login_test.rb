require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'

    assert_select 'form'
    assert_select 'label', count: 2
    assert_select 'input#session_email'
    assert_select 'input#session_password'
    assert_select 'input.btn'

    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end
end

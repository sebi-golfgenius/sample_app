require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:sebi)
  end

  test "unsuccessful edit" do
    log_in_as @user

    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "",
                                              email: "s@t",
                                              password: "asd",
                                              password_confirmation: "ddd"} }
    assert_template 'users/edit'
    assert_select 'div.alert', "The form contains"
    assert_select 'div#error_explenation ul li', count: 4
  end

  test "successful edit" do
    log_in_as @user

    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "foo bvar"
    email = "foo@bar.zar"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "new name"
    email = "new@email.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test "firendly forwarding url setted. Only first login forwards to it" do
    get edit_user_path(@user)
    log_in_as(@user)
    delete logout_path
    log_in_as(@user)
    assert_redirected_to @user
  end
end

require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:sebi)
    @non_admin = users(:archer)
    @nonci = users(:nonci)
  end

  test "index including pagination" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    users = assigns(:users)
    users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and deletion links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = assigns(:users)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      unless user==@admin
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
  end

  test "admin should delete successfully" do
    log_in_as(@admin)
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index page as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text: "delete", count: 0
  end

  test "unactivated user should not be available for display at neither /users nor /users/:id" do
    log_in_as(@admin)
    get users_path
    users = assigns(:users)
    assert_select "a[href=?]", user_path(@nonci), text: @nonci.name, count: 0

    get user_path(@nonci)
    assert_redirected_to root_url
  end

  
end

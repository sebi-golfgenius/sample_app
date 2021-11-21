require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:archer)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=?]', "file"
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explenation'
    assert_select 'a[href=?]', '/home?page=2' # correct pagination link
    # Valid submission
    content = "Test micropost"
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: {content: content, image: image } }
    end
    assert @user.microposts.paginate(page: 1).first.image.attached?
    assert_redirected_to root_url
    follow_redirect!
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit different user (no delete links)
    get user_path(users(:sebi))
    assert_select 'a', text: 'delete', count: 0


  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "65 microposts", response.body
    # User with zero microposts
    other_user = users(:sebi)
    log_in_as(other_user)
    get root_path
    assert_match "1 micropost", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "2 microposts", response.body
  end

end

require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:sebi)
    @micropost = @user.microposts.new(content: "Abra-cadabra", user_id: @user.id)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end

  test "content should be at most 140 chars" do
    @micropost.content = "13"*100;
    assert_not @micropost.valid?
  end

  test "order should be more recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Hocus pocus")

    assert_difference 'Micropost.count', -3 do # we user -2 because one micropost is saved in setup as well
      @user.destroy
    end
  end
end

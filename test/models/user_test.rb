require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "ex", email: "ex@ceva.com",
                    password: "sonicX", password_confirmation: "sonicX")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = 'a' * 256
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                    first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |addr|
      @user.email = addr
      assert @user.valid?, "#{addr.inspect} should be a valid email"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@ceva,com user_at_foo.org user.name@galaxy@terra.com
                            foo@bar+bar.zon foo@bar..com]
    invalid_addresses.each do |addr|
      @user.email = addr
      assert_not @user.valid?, "#{addr} should be an invalid email"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be saved as lower-case" do
    mixed_case = "SonIC@x.com"
    @user.email = mixed_case
    @user.save
    assert_equal mixed_case.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end

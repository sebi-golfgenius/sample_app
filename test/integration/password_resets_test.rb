require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    # clear the deliveries so that we start with 0 mails send
    ActionMailer::Base.deliveries.clear
    @user = users(:sebi)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right eamil, wrong token
    get edit_password_reset_path('wrong token', emial: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                            user: { password: 'foobaz',
                                                                    password_confirmation: 'barquux'} }
    assert_select 'div#error_explenation'
    # Empty password
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password: "",
                                                                   password_confirmation: "" } }
    assert_select 'div#error_explenation'
    # Valid password & password_confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password: "123456",
                                                                   password_confirmation: "123456" } }
    assert_nil user.reload.reset_digest
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_send_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password: '123456',
                            password_confirmation: '123456' } }
    assert_response :redirect
    follow_redirect!
    assert_match 'expired', response.body
  end
end

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new (login form)" do
    get login_path
    assert_response :success
  end

  test "should login user with valid credentials" do
    create(:user, email: "test@example.com", password: "password")

    post login_path, params: {
      email: "test@example.com",
      password: "password"
    }

    assert_redirected_to subscriptions_path
    follow_redirect!
    assert_match "Logged in successfully", response.body
    assert_response :success
  end

  test "should not login with invalid credentials" do
    post login_path, params: {
      email: "invalid@example.com",
      password: "wrong"
    }

    assert_response :unprocessable_entity
    assert_match "Invalid email or password", response.body
  end

  test "should logout user" do
    delete logout_path
    assert_redirected_to login_path
  end
end

require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(email: "test@example.com")
    @user.set_password("password")
    @user.save!

    @subscription1 = Subscription.create!(
      user: @user,
      stripe_subscription_id: "sub_001",
      status: :paid
    )

    @subscription2 = Subscription.create!(
      user: @user,
      stripe_subscription_id: "sub_002",
      status: :unpaid
    )
  end

  test "should get index when logged in" do
    post login_path, params: {
      email: "test@example.com",
      password: "password"
    }

    assert_redirected_to subscriptions_path
    follow_redirect!
    assert_response :success

    assert_match "sub_001", response.body
    assert_match "sub_002", response.body
  end

  test "should redirect index when not logged in" do
    get subscriptions_path
    assert_redirected_to login_path
  end
end

require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @subscription = build(:subscription, user: @user, stripe_subscription_id: "sub_123", status: "unpaid")
  end

  test "should be valid with valid attributes" do
    assert @subscription.valid?
  end

  test "should require a user" do
    @subscription.user = nil
    assert_not @subscription.valid?
    assert_includes @subscription.errors[:user], "must exist"
  end

  test "should have default status as unpaid" do
    subscription = build(:subscription, user: @user)
    assert_equal "unpaid", subscription.status
  end

  test "should allow valid statuses" do
    %w[unpaid paid canceled].each do |status|
      @subscription.status = status
      assert @subscription.valid?, "#{status.inspect} should be valid"
    end
  end

  test "should not allow invalid status" do
    assert_raises ArgumentError do
      @subscription.status = "refunded"
    end
  end
end

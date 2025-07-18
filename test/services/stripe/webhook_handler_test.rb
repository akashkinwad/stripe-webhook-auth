require "test_helper"

class Stripe::WebhookHandlerTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com").tap do |u|
      u.set_password("secret")
      u.save!
    end
  end

  test "handles customer.subscription.created event" do
    event = {
      "type" => "customer.subscription.created",
      "data" => {
        "object" => {
          "id" => "sub_123",
          "metadata" => { "email" => @user.email }
        }
      }
    }

    assert_difference "Subscription.count", 1 do
      Stripe::WebhookHandler.new(event).process!
    end

    subscription = Subscription.last
    assert_equal @user, subscription.user
    assert_equal "sub_123", subscription.stripe_subscription_id
    assert_equal "unpaid", subscription.status
  end

  test "does not create duplicate subscriptions on repeated created event" do
    Subscription.create!(
      user: @user,
      stripe_subscription_id: "sub_123",
      status: "unpaid"
    )

    event = {
      "type" => "customer.subscription.created",
      "data" => {
        "object" => {
          "id" => "sub_123",
          "metadata" => { "email" => @user.email }
        }
      }
    }

    assert_no_difference "Subscription.count" do
      Stripe::WebhookHandler.new(event).process!
    end
  end

  test "handles invoice.payment_succeeded event" do
    subscription = Subscription.create!(
      user: @user,
      stripe_subscription_id: "sub_123",
      status: "unpaid"
    )

    event = {
      "type" => "invoice.payment_succeeded",
      "data" => {
        "object" => {
          "subscription" => "sub_123"
        }
      }
    }

    Stripe::WebhookHandler.new(event).process!
    assert_equal "paid", subscription.reload.status
  end

  test "handles customer.subscription.deleted event" do
    subscription = Subscription.create!(
      user: @user,
      stripe_subscription_id: "sub_123",
      status: "paid"
    )

    event = {
      "type" => "customer.subscription.deleted",
      "data" => {
        "object" => {
          "id" => "sub_123"
        }
      }
    }

    Stripe::WebhookHandler.new(event).process!
    assert_equal "canceled", subscription.reload.status
  end

  test "logs and ignores unknown event types" do
    event = {
      "type" => "unknown.event",
      "data" => {
        "object" => {}
      }
    }

    assert_nothing_raised do
      Stripe::WebhookHandler.new(event).process!
    end
  end
end

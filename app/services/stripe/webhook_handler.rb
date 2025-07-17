module Stripe
  class WebhookHandler
    def initialize(event)
      @event = event
      @type = event["type"]
      @data = event["data"]["object"].to_h
      Rails.logger.info("Subscription data: #{@data.inspect}")
    end

    def process!
      case @type
      when "customer.subscription.created"
        binding.pry
        handle_subscription_created
      when "invoice.payment_succeeded"
        handle_payment_succeeded
      when "customer.subscription.deleted"
        handle_subscription_deleted
      else
        Rails.logger.info("Unhandled Stripe event type: #{@type}")
      end
    end

    private

    def handle_subscription_created
      stripe_id = @data["id"]
      return if ::Subscription.exists?(stripe_subscription_id: stripe_id)

      user = ::User.find_by(email: @data.dig("metadata", "email"))
      return unless user

      ::Subscription.create!(
        user: user,
        stripe_subscription_id: stripe_id,
        status: "unpaid"
      )
    end

    def handle_payment_succeeded
      stripe_id = @data["subscription"]
      subscription = ::Subscription.find_by(stripe_subscription_id: stripe_id)
      return unless subscription

      subscription.update!(status: "paid")
    end

    def handle_subscription_deleted
      stripe_id = @data["id"]
      subscription = ::Subscription.find_by(stripe_subscription_id: stripe_id)
      return unless subscription

      subscription.update!(status: "canceled")
    end
  end
end

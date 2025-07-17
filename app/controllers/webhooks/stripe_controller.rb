module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      event = Stripe::WebhookVerifier.new(
        request_body: request.body.read,
        signature: request.env["HTTP_STRIPE_SIGNATURE"]
      ).verify!

      return head :bad_request if event.nil?

      Stripe::WebhookHandler.new(event).process!

      head :ok
    end
  end
end

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

      begin
        if Rails.env.development? || Rails.env.test?
          event = JSON.parse(payload)
        else
          event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
        end
      rescue JSON::ParserError => e
        Rails.logger.error("Webhook JSON parsing failed: #{e.message}")
        return head :bad_request
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error("Webhook signature verification failed: #{e.message}")
        return head :bad_request
      end

      Stripe::WebhookHandler.new(event).process!

      head :ok
    end
  end
end

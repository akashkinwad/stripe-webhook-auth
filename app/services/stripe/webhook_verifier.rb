module Stripe
  class WebhookVerifier
    def initialize(request_body:, signature:)
      @payload = request_body
      @sig_header = signature
      @secret = ENV["STRIPE_WEBHOOK_SECRET"]
    end

    def verify!
      ::Stripe::Webhook.construct_event(@payload, @sig_header, @secret)
    rescue JSON::ParserError, ::Stripe::SignatureVerificationError
      nil
    end
  end
end

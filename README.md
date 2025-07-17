# Stripe Webhook Auth

A simple Ruby on Rails(V8) app that handles Stripe webhook events for subscription creation, payment success, and subscription cancellation.

## Prerequisites

- Ruby 3.3.0
- Rails 8
- Sqlite3
- Bundler

## Getting Started

### 1. Install Ruby 3.3.0

Install Ruby using [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) if not already installed.

```bash
rbenv install 3.3.0
rbenv local 3.3.0
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Set up the database

```bash
rails db:create db:migrate db:seed
```

### 4. Start the Rails server

```bash
rails s
```

### 5. Login

Visit: [http://localhost:3000/login](http://localhost:3000/login)

Use the following credentials (seeded):

- **Email**: `test@example.com`
- **Password**: `secret123`

## Stripe Webhook Testing

You can test the webhook endpoints using `curl`. Make sure the Rails server is running at `localhost:3000`.

### 1. Subscription Created

```bash
curl -X POST http://localhost:3000/webhooks/stripe \
  -H "Content-Type: application/json" \
  -H "Stripe-Signature: t=123,v1=fake_signature" \
  -d @subscription_created.json
```

### 2. Payment Succeeded

```bash
curl -X POST http://localhost:3000/webhooks/stripe \
  -H "Content-Type: application/json" \
  -H "Stripe-Signature: t=123,v1=fake_signature" \
  -d @payment_succeeded.json
```

### 3. Subscription Deleted

```bash
curl -X POST http://localhost:3000/webhooks/stripe \
  -H "Content-Type: application/json" \
  -H "Stripe-Signature: t=123,v1=fake_signature" \
  -d @subscription_deleted.json
```

## JSON Payload Files

Ensure you have the following files in your project root (or adjust the paths in the curl command accordingly):

- `subscription_created.json`
- `payment_succeeded.json`
- `subscription_deleted.json`

These contain mock Stripe event payloads used for testing. Example for `subscription_created.json`:

```json
{
  "id": "evt_1TestSubCreated",
  "object": "event",
  "type": "customer.subscription.created",
  "data": {
    "object": {
      "id": "sub_1TestSub123",
      "object": "subscription",
      "customer": "cus_12345",
      "status": "active",
      "metadata": {
        "email": "test@example.com"
      },
      "items": {
        "object": "list",
        "data": [
          {
            "id": "si_123",
            "object": "subscription_item",
            "price": {
              "id": "price_123",
              "object": "price",
              "unit_amount": 1000,
              "currency": "usd",
              "recurring": {
                "interval": "month"
              },
              "product": "prod_123"
            },
            "quantity": 1
          }
        ]
      }
    }
  }
}
```
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
  -d @invoice_payment_succeeded.json
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
- `invoice_payment_succeeded.json`
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

## Minitest Result


```
➜  stripe-webhook-auth git:(main) ✗ rails test

Running 23 tests in a single process (parallelization threshold is 50)
Started with run options --seed 12458

SubscriptionTest
  ✓ should have default status as unpaid
  ✓ should allow valid statuses
  ✓ should be valid with valid attributes
  ✓ should require a user
  ✓ should not allow invalid status

Stripe::WebhookHandlerTest
  ✓ handles customer.subscription.deleted event
  ✓ does not create duplicate subscriptions on repeated created event
  ✓ handles customer.subscription.created event
  ✓ logs and ignores unknown event types
  ✓ handles invoice.payment_succeeded event

SubscriptionsControllerTest
  ✓ should redirect index when not logged in
  ✓ should get index when logged in

SessionsControllerTest
  ✓ should not login with invalid credentials
  ✓ should get new (login form)
  ✓ should login user with valid credentials
  ✓ should logout user

UserTest
  ✓ should be valid with email and password_digest
  ✓ should enforce unique email
  ✓ authenticate should return nil for unknown email
  ✓ authenticate should return user for correct credentials
  ✓ authenticate should return nil for wrong password
  ✓ set_password should hash the password correctly
  ✓ should require email

Finished in 0.24555s
✔ 23 tests, 50 assertions, 0 failures, 0 errors, 0 skips
```

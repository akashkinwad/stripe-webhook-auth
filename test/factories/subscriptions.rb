FactoryBot.define do
  factory :subscription do
    association :user
    stripe_subscription_id { "sub_#{SecureRandom.hex(4)}" }
    status { :unpaid }

    trait :unpaid do
      status { :unpaid }
    end

    trait :paid do
      status { :paid }
    end

    trait :canceled do
      status { :canceled }
    end
  end
end

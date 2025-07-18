FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }

    transient do
      password { "securepass" }
    end

    after(:build) do |user, evaluator|
      user.set_password(evaluator.password)
    end
  end
end

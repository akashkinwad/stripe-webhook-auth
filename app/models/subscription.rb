class Subscription < ApplicationRecord
  belongs_to :user

  enum :status, { unpaid: 0, paid: 1, canceled: 2 }
end

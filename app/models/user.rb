require "digest"

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  has_many :subscriptions

  def self.authenticate(email, password)
    user = find_by(email: email)
    return nil unless user

    hashed = Digest::SHA256.hexdigest(password + Rails.application.secret_key_base)
    user if user.password_digest == hashed
  end

  def set_password(password)
    self.password_digest = Digest::SHA256.hexdigest(password + Rails.application.secret_key_base)
  end
end

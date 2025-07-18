require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with email and password_digest" do
    user = build(:user)
    assert user.valid?
  end

  test "should require email" do
    user = build(:user, email: "")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should enforce unique email" do
    create(:user, email: "test@example.com", password: "securepass")
    duplicate_user = build(:user, email: "test@example.com", password: "anotherpass")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "set_password should hash the password correctly" do
    user = build(:user)
    raw_password = "secret123"
    user.set_password(raw_password)
    expected_hash = Digest::SHA256.hexdigest(raw_password + Rails.application.secret_key_base)
    assert_equal expected_hash, user.password_digest
  end

  test "authenticate should return user for correct credentials" do
    create(:user, email: "test@example.com", password: "securepass")
    result = User.authenticate("test@example.com", "securepass")
    assert result
    assert_equal "test@example.com", result.email
  end

  test "authenticate should return nil for wrong password" do
    create(:user, email: "test@example.com", password: "securepass")
    result = User.authenticate("test@example.com", "wrongpass")
    assert_nil result
  end

  test "authenticate should return nil for unknown email" do
    create(:user, email: "test@example.com", password: "securepass")
    result = User.authenticate("unknown@example.com", "securepass")
    assert_nil result
  end
end

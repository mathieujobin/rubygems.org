FactoryBot.define do
  factory :user do
    email
    handle
    password { PasswordHelpers::SECURE_TEST_PASSWORD }
    api_key { "secret123" }
    email_confirmed { true }

    trait :mfa_enabled do
      mfa_seed { "123abc" }
      mfa_level { User.mfa_levels["ui_and_api"] }
      mfa_recovery_codes { %w[aaa bbb ccc] } # TODO: make transient once the column is dropped
      hashed_mfa_recovery_codes { mfa_recovery_codes.map { |code| BCrypt::Password.create(code) } }
    end
  end
end

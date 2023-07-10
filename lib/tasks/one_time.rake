namespace :one_time do
  desc "Populate totp_seed from mfa_seed"
  task populate_totp_seed: :environment do
    User.where.not(mfa_seed: nil).update_all("totp_seed = mfa_seed")
  end

  desc "Assign ui_and_gem_signin to webauthn only users"
  task assign_ui_and_gem_signin: :environment do
    User.where(mfa_level: :disabled).where(id: WebauthnCredential.select(:user_id)).update_all(mfa_level: :ui_and_gem_signin)
  end

  desc "Hash mfa recovery codes"
  task hash_recovery_codes: :environment do
    User.where(hashed_mfa_recovery_codes: nil).where.not(mfa_recovery_codes: nil).find_each do |user|
      user.hashed_mfa_recovery_codes = user.mfa_recovery_codes.map { |code| BCrypt::Password.create(code) }
      user.save!(validate: false)
    end
  end

  desc "Remove plain text recovery codes"
  task remove_plain_text_recovery_codes: :environment do
    User.where.not(mfa_recovery_codes: nil).update_all(mfa_recovery_codes: [])
  end
end

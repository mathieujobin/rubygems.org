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
    batch_size = ENV.fetch("BATCH_SIZE", 150).to_i
    User.where(mfa_hashed_recovery_codes: []).where.not(mfa_recovery_codes: []).find_each(batch_size:) do |user|
      user.mfa_hashed_recovery_codes = user.mfa_recovery_codes.map { |code| BCrypt::Password.create(code) }
      user.save!(validate: false)
    end
  end
end

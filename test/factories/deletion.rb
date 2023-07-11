FactoryBot.define do
  factory :deletion do
    user
    rubygem
    number
    platform { "ruby" }
  end
end

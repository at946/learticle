FactoryBot.define do
  factory :article do
    url { Faker::Internet.url }
  end
end
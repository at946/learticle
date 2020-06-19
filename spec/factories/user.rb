FactoryBot.define do
  factory :user do
    auth0_uid { Faker::Alphanumeric.alpha(number: 20) }
    name      { Faker::Name.name }
    image     { Faker::Avatar.image }
  end
end
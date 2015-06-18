FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email-#{n}@example.com" }
    password '12345678'

    factory :admin_user do
      is_admin true
    end
  end
end

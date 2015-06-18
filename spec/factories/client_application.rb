FactoryGirl.define do
  factory :client_application, class: Doorkeeper::Application do
    sequence(:name) { |n| "app-#{n}" }
    redirect_uri 'https://example.com'
  end
end

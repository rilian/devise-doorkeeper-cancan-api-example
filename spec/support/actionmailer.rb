RSpec.configure do |config|
  config.after :each do
    ActionMailer::Base.deliveries.clear
  end
end

module Auth0Helper
  OmniAuth.config.test_mode = true

  # Mock userでログイン
  def login(uid = 'google-oauth2|123456789012345678901')
    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new({
      :provider => 'auth0',
      :uid => uid
    })

    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:auth0]

    visit root_path
    click_on :login_button
  end

  def logout
    visit articles_path
    click_on :logout_button
  end
end
  
RSpec.configure do |config|
  config.include Auth0Helper, type: :system
end
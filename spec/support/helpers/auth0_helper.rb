module Auth0Helper
  OmniAuth.config.test_mode = true

  # Mock userでログイン
  def login(user, logout: true, &block)
    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new({
      :provider => 'auth0',
      :uid => user.auth0_uid,
      :info => {
        :name => user.name,
        :image => user.image
      }
    })

    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:auth0]

    visit root_path
    click_on :login_button

    block.call

    if logout
      visit articles_path(type: :reading_later)
      click_on :logout_button
    end
  end
end
  
RSpec.configure do |config|
  config.include Auth0Helper, type: :system
end
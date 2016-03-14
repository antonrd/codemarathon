module OmniauthHelpers
  def mock_auth_hash provider_name, email=nil
    OmniAuth.config.mock_auth[provider_name] = OmniAuth::AuthHash.new({
      provider: provider_name.to_s,
      uid: '123456',
      credentials: {
        token: "sample-token",
        expires_at: 1.hours.from_now.to_i
      },
      info: {
        name: "Some Name",
        email: email || "some@email.com"
      }
    })
  end
end

OmniAuth.config.test_mode = true

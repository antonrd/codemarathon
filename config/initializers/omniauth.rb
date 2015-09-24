OmniAuth.config.test_mode = true if Rails.env.test?
# OmniAuth.config.logger = Rails.logger

# Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook, FACEBOOK_APP_ID, FACEBOOK_SECRET,
  #   {
  #     image_size: :square,
  #     secure_image_url: true,
  #     display: :popup
  #   }
  # provider :google_oauth2, GOOGLE_APP_ID, GOOGLE_SECRET,
  #   {
  #     image_aspect_ratio: "square",
  #     image_size: 50,
  #     scoe: "email, profile"
  #   }
  # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email"
  # provider :linkedin, LINKEDIN_API_KEY, LINKEDIN_SECRET_KEY,
  #   :fields => ['id', 'email-address', 'first-name', 'last-name', 'picture-url']
# end

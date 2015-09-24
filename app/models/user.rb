class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2, :github]

  def self.from_omniauth(auth)
    Rails.logger.info(auth.info.name)
    where(email: auth.info.email).first_or_create do |user|
    # where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      # user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.save
      # user.image = auth.info.image # assuming the user model has an image
    end
  end

  def display_name
    name || email
  end
end

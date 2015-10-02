class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2, :github]

  has_many :roles

  ROLE_ADMIN = :admin
  ROLE_TEACHER = :teacher
  ROLES = [ROLE_ADMIN, ROLE_TEACHER]

  def self.from_omniauth(auth)
    Rails.logger.info(auth.info.name)
    where(email: auth.info.email).first_or_create do |user|
    # where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      # user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      # Mark user as confirmed because there is no point in confirming when
      # authorizing with OAuth
      user.confirmed_at = DateTime.now
      user.save
      # user.image = auth.info.image # assuming the user model has an image
    end
  end

  def display_name
    name.present? ? name : email
  end

  def display_roles
    roles.map(&:role_type).join(", ")
  end

  def registered_with_email?
    provider.nil?
  end

  def add_role role_type
    roles.find_or_create_by(role_type: role_type)
  end

  def remove_role role_type
    matched_role = roles.where(role_type: role_type)
    matched_role.destroy_all if matched_role.present?
  end

  def has_role? role_type
    roles.where(role_type: role_type).present?
  end
end

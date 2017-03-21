class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2, :github, :facebook]

  has_many :classroom_records, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :task_records, dependent: :destroy
  has_many :task_runs, dependent: :destroy
  has_many :quiz_attempts

  validates :email, presence: true

  ROLE_ADMIN = :admin
  ROLE_TEACHER = :teacher
  ROLES = [ROLE_ADMIN, ROLE_TEACHER]

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :with_access, -> { where(active: true).where.not(confirmed_at: nil) }
  scope :no_access, -> { where('active = false OR confirmed_at IS NULL') }
  scope :by_name_email, ->(query) { where('email LIKE ? OR name LIKE ?', "%#{ query }%", "%#{ query }%") }

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      # Mark user as confirmed because there is no point in confirming when
      # authorizing with OAuth
      user.confirmed_at = DateTime.now
      user.save
    end

    user.set_active_field

    user
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

  def is_teacher?
    has_role?(ROLE_TEACHER)
  end

  def set_active_field
    User.transaction do
      update_attributes(active: true) if can_activate_user?
    end
    true
  end

  private

  def can_activate_user?
    use_invitation || Settings.users_limit.nil? ||
      Settings.users_limit == -1 || User.active.count < Settings.users_limit
  end

  def use_invitation
    invitation = UserInvitation.find_by(email: email)

    if invitation.present? && !invitation.used?
      invitation.update_attributes(used: true, used_at: Time.now)
      true
    else
      false
    end
  end
end

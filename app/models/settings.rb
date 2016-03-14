class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env

  def localized
    public_send(I18n.locale)
  end
end

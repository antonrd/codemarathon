# encoding: utf-8

##
# Backup Generated: codemarathon_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t codemarathon_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
Model.new(:codemarathon_backup, 'Backup of PG DB') do
  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "codemarathon_production"
    db.username           = ""
    db.password           = ""
    db.host               = "localhost"
    db.port               = 5432
    # db.socket             = "/var/run/postgresql"
    db.socket             = "/tmp"
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    # db.additional_options = ["-xc", "-E=utf8"]
  end

  ##
  # Dropbox [Storage]
  #
  # Your initial backup must be performed manually to authorize
  # this machine with your Dropbox account. This authorized session
  # will be stored in `cache_path` and used for subsequent backups.
  #
  store_with Dropbox do |db|
    db.api_key     = ""
    db.api_secret  = ""
    # Sets the path where the cached authorized session will be stored.
    # Relative paths will be relative to ~/Backup, unless the --root-path
    # is set on the command line or within your configuration file.
    db.cache_path  = ".cache"
    # :app_folder (default) or :dropbox
    db.access_type = :app_folder
    db.path        = "."
    db.keep        = 25
    # db.keep        = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "backup@hiredintech.com"
    mail.to                   = ""
    # mail.cc                   = "cc@email.com"
    # mail.bcc                  = "bcc@email.com"
    mail.reply_to             = "backup@hiredintech.com"
    mail.address              = "smtp.mailgun.org"
    mail.port                 = 587
    mail.domain               = "train.hiredintech.com"
    mail.user_name            = ""
    mail.password             = ""
    # mail.authentication       = "plain"
    # mail.encryption           = :starttls
  end

end

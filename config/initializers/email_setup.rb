ActionMailer::Base.smtp_settings = {
  user_name: ENV['SENDGRID_USERNAME'],
  password:  ENV['SENDGRID_PASSWORD'],
  domain:    'infinite-river-7560.herokuapp.com',
  address:   'smtp.sendgrid.net',
  port:      587,
  authentication: :plain,
  enable_starttls_auto: true
}

ActionMailer::Base.delivery_method = :smtp
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['AWS_KEY'],
    aws_secret_access_key: ENV['AWS_SECRET']
  }
  
  config.fog_directory = "unlockgatedev"
  config.fog_public = false
end
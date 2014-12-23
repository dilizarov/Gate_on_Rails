if Rails.env.production?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:url => ENV["REDISTOGO_URL"])
else
  REDIS = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
end
# Temporary hack. That hurt to write. Keys no longer expire.

class KeyRefresher
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  recurrence do 
    daily.hour_of_day(0).minute_of_hour(1)
  end
  
  def perform
    Key.all.map(&:touch)
  end
end
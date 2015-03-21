# Temporary hack. That hurt to write. Keys no longer expire.

class KeyRefresher
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  recurrence { daily }
  
  def perform(*args)
    Key.all.map(&:touch)
  end
end
class Notifications
  include Sidekiq::Worker
  
  def perform
    destination = ["lel"]
    
    data = {
      :key = "Hello there"
    }
    
    GCM.send_notification(destination, data)
  end
end
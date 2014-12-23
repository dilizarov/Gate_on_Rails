require 'pushwithme'

class Notifications
  include Sidekiq::Worker

  # args[0]  : Notification Type
  # args[1] : Current User ID
  # args[2..-1] : Vary according to Notification Type
  def perform(*args)
    
    case args[0]
    when POST_CREATED_NOTIFICATION
      send_post_created_notification(args)
    when GATE_JOINED_NOTIFICATION
      send_gate_joined_notification(args)
    when COMMENT_CREATED_NOTIFICATION
      send_comment_created_notification(args)
    when POST_LIKED_NOTIFICATION
      send_post_liked_notification(args)
    when COMMENT_LIKED_NOTIFICATION
      send_comment_liked_notification(args)
    end
  end
  
  def send_post_created_notification(args)
    current_user_id   = args[1]
    current_user_name = args[2]
    post_network_id   = args[3]
    post_body         = args[4]
    
    network = Network.find(post_network_id)
    return unless network
    
    destinations = network.devices.where('users.id != ?', current_user_id).map(&:token)
    
    message = "#{current_user_name} just posted in #{network.name}: #{post_body}"
    
    data = {
      notification_type: args[0]
      message: message
    }
    
    GCM.send_notification(destinations, data)
  end
end
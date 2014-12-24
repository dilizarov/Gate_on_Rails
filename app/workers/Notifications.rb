require 'pushmeup'

class Notifications
  include Sidekiq::Worker
  sidekiq_options :retry => false 

  # args[0]  : Notification Type
  # args[1] : Current User ID
  # args[2..-1] : Vary according to Notification Type
  def perform(*args)
        
    case args[0]
    when POST_CREATED_NOTIFICATION
      send_post_created_notification(args)
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

    return if destinations.empty?
    
    title = "New Post"
    summary = "#{current_user_name} just posted in #{network.name}"
    
    data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      gate: network.name,
      poster: current_user_name,
      post_body: post_body
    }
    
    GCM.send_notification(destinations, data)
  end
  
  def send_comment_created_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    comment_post_id   = args[3]
    comment_body      = args[4]
    
    post = Post.find(comment_post_id)
    return unless post
    
    user_ids = post.comments.where.not(user_id: current_user_id).map(&:user_id)
    user_ids << post.user_id unless post.user_id == current_user_id
    user_ids.uniq!
    
    destinations = Device.where(user_id: user_ids).map(&:token)
    
    return if destinations.empty?
    
    message = "#{current_user_name} just commented on a post: #{comment_body}"
        
    data = {
      notification_type: args[0],
      message: message,
      commenter: current_user_name,
      comment_body: comment_body
    }
    
    GCM.send_notification(destinations, data)
  end
  
  def send_post_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    post_user_id      = args[3]
    
    return if post_user_id == current_user_id
    
    destinations = Device.where(user_id: post_user_id).map(&:token)
    
    return if destinations.empty?
    
    message = "#{current_user_name} just liked your post"
    
    data = {
      notification_type: args[0],
      message: message,
      liker: current_user_name
    }
    
    GCM.send_notification(destinations, data)
  end
  
  def send_comment_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    comment_user_id   = args[3]
    
    return if comment_user_id == current_user_id
    
    destinations = Device.where(user_id: comment_user_id).map(&:token)
    
    return if destinations.empty?
    
    message = "#{current_user_name} just liked your comment"
    
    data = {
      notification_type: args[0],
      message: message,
      liker: current_user_name
    }
    
    GCM.send_notification(destinations, data)
  end
end
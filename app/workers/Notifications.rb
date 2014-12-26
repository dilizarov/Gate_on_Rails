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
    
    summary = "#{current_user_name} just posted"
    extended_text = "#{current_user_name} - #{post_body}"
    
    data = {
      notification_type: args[0],
      summary: summary,
      gate: network.name,
      extended_text: extended_text,
      poster: current_user_name,
      post_body: post_body
    }
    
    GCM.send_notification(destinations, data)
  end
  
  # A lot of work is done here to figure out who liked the post and who didn't
  # So that the proper data gets sent to their phone
  # This is important because when some clicks on the notification
  # in Android, we don't request the Post, we just load it from the data,
  # which is how it gets the post data from the feed.
  # Just makes life easier on the android side.
  def send_comment_created_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    comment_post_id   = args[3]
    comment_body      = args[4]
    
    post = Post.eager_load(:user, :network).find(comment_post_id)
    
    user_ids = post.comments.where.not(user_id: current_user_id).map(&:user_id)
    user_ids << post.user_id unless post.user_id == current_user_id
    user_ids.uniq!
    
    # Array of user_ids that liked post
    all_users_who_liked_post = ActsAsVotable::Vote.where(
    voter_type: User, votable_id: post.id, votable_type: Post, vote_scope: nil,
    vote_flag: true).pluck(:voter_id)
    
    # Send notifications with liked post to dest_liked.
    # Send notifications with unliked post to dest_unliked.
    dest_liked, dest_unliked = Device.where(user_id: user_ids).partition do |device|
      all_users_who_liked_post.include? device.user_id
    end
      
    return if dest_liked.empty? && dest_unliked.empty?
    
    title = "new comment"
    summary = "#{current_user_name} commented on related post"
    extended_text = "#{current_user_name} - #{comment_body}"
     
    data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      commenter: current_user_name,
      comment_body: comment_body,
    }

    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      network_external_id: post.network.external_id,
      network_name: post.network.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: true,
      created_at: post.created_at
    }
    
    data[:post] = post_data.values
    notif_liked = GCM::Notification.new(dest_liked.map(&:token), data)
    
    # You have to dup data, because GCM::Notification keeps a reference
    # and if we change data[:post] here, the above changes meaning all this
    # work is for naught.
    post_data[:liked] = false
    data_unliked = data.dup
    data_unliked[:post] = post_data.values
    notif_unliked = GCM::Notification.new(dest_unliked.map(&:token), data_unliked)
    
    notifications = []
    notifications << notif_liked unless dest_liked.empty?
    notifications << notif_unliked unless dest_unliked.empty?
    
    GCM.send_notifications(notifications)
  end
  
  def send_post_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    post_user_id      = args[3]
    post_id           = args[4]
    
    return if post_user_id == current_user_id
    
    post = Post.eager_load(:user, :network).find(post_id)
    
    destinations = Device.where(user_id: post_user_id).map(&:token)
    
    return if destinations.empty?
    
    title = "new like"
    summary = "#{current_user_name} liked your post"
    extended_text = "#{current_user_name} liked your post - #{post.body}"
        
    data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      liker: current_user_name
    }
    
    liked_post = ActsAsVotable::Vote.where(
    voter_type: User, voter_id: post_user_id, votable_type: Post, votable_id: post.id,
    vote_scope: nil, vote_flag: true).count > 0
    
    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      network_external_id: post.network.external_id,
      network_name: post.network.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: liked_post,
      created_at: post.created_at
    }
    
    data[:post] = post_data.values
        
    GCM.send_notification(destinations, data)
  end
  
  def send_comment_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    comment_body      = args[3]
    comment_user_id   = args[4]
    post_id           = args[5]
    
    post = Post.eager_load(:user, :network).find(post_id)
    return if comment_user_id == current_user_id
    
    destinations = Device.where(user_id: comment_user_id).map(&:token)
    
    return if destinations.empty?
    
    title = "new like"
    summary = "#{current_user_name} liked your comment"
    extended_text = "#{current_user_name} liked your comment - #{comment_body}"
        
    data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      liker: current_user_name
    }
    
    liked_post = ActsAsVotable::Vote.where(
    voter_type: User, voter_id: comment_user_id, votable_type: Post, votable_id: post.id,
    vote_scope: nil, vote_flag: true).count > 0
    
    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      network_external_id: post.network.external_id,
      network_name: post.network.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: liked_post,
      created_at: post.created_at
    }
    
    data[:post] = post_data.values
        
    GCM.send_notification(destinations, data)
  end
end
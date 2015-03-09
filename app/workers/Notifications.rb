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
    when GENERATED_GATES_NOTIFICATION
      send_unlocked_gates_notification(args)
    end
  end
  
  def send_post_created_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    post_gate_id      = args[3]
    post_body         = args[4]
    
    gate = Gate.find(post_gate_id)
    return unless gate
    
    devices = gate.devices.where('users.id != ?', current_user_id)

    # If the gate is generated, only send a notification to those who have
    # permanently unlocked the Gate
    if gate.generated
      # key is user_id of Device
      hash_of_user_gates = UserGate.where(user_id: devices.map(&:user_id), gate_id: gate.id, auth_token_id: nil).index_by(&:user_id)
      
      devices.select! do |device|
        !!hash_of_user_gates[device.user_id]
      end
    end

    android_destinations = []
    ios_destinations = []
    
    devices.each do |device|
      if device.platform == "android"
        android_destinations << device.token
      elsif device.platform == "ios"
        ios_destinations << device.token
      end
    end
      
    return if android_destinations.empty? && ios_destinations.empty?
    
    title = "Gate"
    summary = "#{current_user_name} posted in #{gate.name}"
    extended_text = "#{current_user_name} posted in #{gate.name}: \n\n #{post_body}"
    
    android_data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      poster: current_user_name,
      post_body: post_body,
      gate_name: gate.name,
      gate_id: gate.external_id
    }
    
    GCM.send_notification(android_destinations, android_data) unless android_destinations.empty?
    
    ios_data = {
      alert: summary,
      badge: 0,
      sound: "default",
      other: { notification_type: args[0], poster: current_user_name, gate_name: gate.name, gate_id: gate.external_id }
    }
    
    notifications = ios_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
    
    APNS.send_notifications(notifications) unless ios_destinations.empty?
    
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
    
    post = Post.eager_load(:user, :gate).find(comment_post_id)
    
    user_ids = post.comments.where.not(user_id: current_user_id).map(&:user_id)
    user_ids << post.user_id unless post.user_id == current_user_id
    
    # Users being notified need to be in the Gate.
    # This is for cases when someone leaves a Gate.
    user_ids = UserGate.where(user_id: user_ids,
                                 gate_id: post.gate_id)
                          .map(&:user_id)
                          .uniq
    
    # Array of user_ids that liked post
    all_users_who_liked_post = ActsAsVotable::Vote.where(
    voter_type: User, votable_id: post.id, votable_type: Post, vote_scope: nil,
    vote_flag: true).pluck(:voter_id)
    
    # Send notifications with liked post to dest_liked.
    # Send notifications with unliked post to dest_unliked.
    devices_liked, devices_unliked = Device.where(user_id: user_ids).partition do |device|
      all_users_who_liked_post.include? device.user_id
    end
      
    return if devices_liked.empty? && devices_unliked.empty?
    
    android_liked_destinations = []
    ios_liked_destinations = []
    android_unliked_destinations = []
    ios_unliked_destinations = []
    
    devices_liked.each do |device|
      if device.platform == "android"
        android_liked_destinations << device.token
      elsif device.platform == "ios"
        ios_liked_destinations << device.token
      end
    end
    
    devices_unliked.each do |device|
      if device.platform == "android"
        android_unliked_destinations << device.token
      elsif device.platform == "ios"
        ios_unliked_destinations << device.token
      end
    end
    
    title = "Gate"
    summary = "#{current_user_name} commented on a post"
    extended_text = "#{current_user_name} commented: \n\n #{comment_body}"
     
    android_data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      commenter: current_user_name,
      comment_body: comment_body
    }
    
    ios_data = {
      alert: summary,
      badge: 0,
      sound: "default",
      other: { notification_type: args[0], post_id: post.external_id }
    }

    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      gate_external_id: post.gate.external_id,
      gate_name: post.gate.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: true,
      created_at: post.created_at
    }
    
    android_data[:post] = post_data.values
    
    android_notif_liked = GCM::Notification.new(android_liked_destinations, android_data) unless android_liked_destinations.empty?
    
    ios_liked_notifications = ios_liked_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
    
    APNS.send_notifications(ios_liked_notifications) unless ios_liked_destinations.empty?
    
    # You have to dup data, because GCM::Notification, and APNS::Notification keep a reference
    # and if we change data[:post] here, the above changes meaning all this
    # work is for naught.
    post_data[:liked] = false
    
    android_data_unliked = android_data.dup
    android_data_unliked[:post] = post_data.values
    
    ios_data_unliked = ios_data.dup
    
    android_notif_unliked = GCM::Notification.new(android_unliked_destinations, android_data_unliked) unless android_unliked_destinations.empty?
    
    ios_unliked_notifications = ios_unliked_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
    
    APNS.send_notifications(ios_unliked_notifications) unless ios_unliked_destinations.empty?
    
    notifications = []
    notifications << android_notif_liked unless android_liked_destinations.empty?
    notifications << android_notif_unliked unless android_unliked_destinations.empty?
    
    GCM.send_notifications(notifications)
  end
  
  def send_post_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    post_user_id      = args[3]
    post_id           = args[4]
    
    return if post_user_id == current_user_id
    
    post = Post.eager_load(:user, :gate).find(post_id)
    
    # User being notified needs to be in the Gate.
    # This is for cases when someone leaves a Gate.
    return if UserGate.find_by(user_id: post_user_id, gate_id: post.gate.id).nil?
    
    devices = Device.where(user_id: post_user_id)
    
    android_destinations = []
    ios_destinations = []
    
    devices.each do |device|
      if device.platform == "android"
        android_destinations << device.token
      elsif device.platform == "ios"
        ios_destinations << device.token
      end
    end
      
    return if android_destinations.empty? && ios_destinations.empty?
    
    title = "Gate"
    summary = "#{current_user_name} likes your post"
    extended_text = "#{current_user_name} likes your post: \n\n #{post.body}"
        
    android_data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      liker: current_user_name
    }
    
    ios_data = {
      alert: summary,
      badge: 0,
      sound: "default",
      other: { notification_type: args[0], post_id: post.external_id }
    }
    
    liked_post = ActsAsVotable::Vote.where(
    voter_type: User, voter_id: post_user_id, votable_type: Post, votable_id: post.id,
    vote_scope: nil, vote_flag: true).count > 0
    
    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      gate_external_id: post.gate.external_id,
      gate_name: post.gate.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: liked_post,
      created_at: post.created_at
    }
    
    android_data[:post] = post_data.values
    
    GCM.send_notification(android_destinations, android_data) unless android_destinations.empty?
    
    notifications = ios_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
    
    APNS.send_notifications(notifications) unless ios_destinations.empty?
  end
  
  def send_comment_liked_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    comment_body      = args[3]
    comment_user_id   = args[4]
    post_id           = args[5]
    
    return if comment_user_id == current_user_id
    
    post = Post.eager_load(:user, :gate).find(post_id)
    
    # User being notified needs to be in the Gate.
    # This is for cases when someone leaves a Gate.
    return if UserGate.find_by(user_id: comment_user_id, gate_id: post.gate.id).nil?
    
    devices = Device.where(user_id: comment_user_id)
    
    android_destinations = []
    ios_destinations = []
    
    devices.each do |device|
      if device.platform == "android"
        android_destinations << device.token
      elsif device.platform == "ios"
        ios_destinations << device.token
      end
    end
    
    return if android_destinations.empty? && ios_destinations.empty?
    
    title = "Gate"
    summary = "#{current_user_name} likes your comment"
    extended_text = "#{current_user_name} likes your comment: \n\n #{comment_body}"
        
    android_data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text,
      liker: current_user_name
    }
    
    ios_data = {
      alert: summary,
      badge: 0,
      sound: "default",
      other: { notification_type: args[0], post_id: post.external_id }
    }
    
    liked_post = ActsAsVotable::Vote.where(
    voter_type: User, voter_id: comment_user_id, votable_type: Post, votable_id: post.id,
    vote_scope: nil, vote_flag: true).count > 0
    
    post_data = {
      external_id: post.external_id,
      user_name: post.user.name,
      body: post.body,
      gate_external_id: post.gate.external_id,
      gate_name: post.gate.name,
      comments_count: post.comments_count,
      votes_up: post.cached_votes_up,
      liked: liked_post,
      created_at: post.created_at
    }
    
    android_data[:post] = post_data.values
  
    GCM.send_notification(android_destinations, android_data) unless android_destinations.empty?
    
    notifications = ios_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
    
    APNS.send_notifications(notifications) unless ios_destinations.empty?
  end
  
  def send_unlocked_gates_notification(args)
    
    current_user_id   = args[1]
    current_user_name = args[2]
    new_gate_names    = args[3]
  
    return if new_gate_names.empty?
    
    devices = User.find(current_user_id).devices

    android_destinations = []
    ios_destinations = []
  
    devices.each do |device|
      if device.platform == "android"
        android_destinations << device.token
      elsif device.platform == "ios"
        ios_destinations << device.token
      end
    end
    
    return if android_destinations.empty? && ios_destinations.empty?
  
    gates_string = ""
    
    if new_gate_names.length == 1
      gates_string += new_gate_names[0]
    elsif new_gate_names.length == 2
      gates_string += "#{new_gate_names[0]} and #{new_gate_names[1]}"
    elsif new_gate_names.length == 3
      gates_string += "#{new_gate_names[0]}, #{new_gate_names[1]}, and #{new_gate_names[2]}"
    else
      # string concat variables lol
      gates_string += "#{new_gate_names[0]}, #{new_gate_names[1]}, #{new_gate_names[2]}, and #{num = new_gate_names.length - 3} more Gate#{num > 1 ? "s" : "" }"
    end
      
    title = "Gate"
    summary = "You unlocked #{new_gate_names.length == 1 ? "a Gate" : "Gates"}"
    extended_text = "You unlocked #{gates_string}"
  
    android_data = {
      notification_type: args[0],
      title: title,
      summary: summary,
      extended_text: extended_text
    }
  
    GCM.send_notification(android_destinations, android_data) unless android_destinations.empty?
  
    ios_data = {
      alert: extended_text,
      badge: new_gate_names.count,
      other: { notification_type: args[0] }
    }
  
    notifications = ios_destinations.map do |ios_dest|
      APNS::Notification.new(ios_dest, ios_data)
    end
  
    APNS.send_notifications(notifications) unless ios_destinations.empty?
  end
end
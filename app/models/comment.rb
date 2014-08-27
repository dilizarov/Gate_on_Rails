class Comment < ActiveRecord::Base
  include Externalable

  validates :user_id,     presence: true
  validates :post_id,     presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  after_create  :add_to_feed        
  after_destroy :remove_from_feed
  
  belongs_to :user
  belongs_to :post
  
  def add_to_feed
    parsed_post = get_parsed_post
    return if parsed_post.nil?
    
    parsed_post["post"]["comments"].push(serialized_comment)
    REDIS.hset(feed_network_key, self.post_id, parsed_post.to_json)
  end

  def remove_from_feed    
    parsed_post = get_parsed_post
    return if parsed_post.nil?
      
    comments = parsed_post["post"]["comments"]
    parsed_post["post"]["comments"] = comments.delete_if do |comment| 
      comment["comment"]["external_id"] == self.external_id
    end
    
    REDIS.hset(feed_network_key, self.post_id, parsed_post.to_json)
  end
  
  def serialized_comment(options = {})
    serialization = CommentSerializer.new(self)
    options[:jsonified] ? serialization.to_json : serialization
  end
  
  def get_parsed_post
    feed_post = REDIS.hget(feed_network_key, self.post_id)
    
    feed_post.present? ? JSON.parse(feed_post) : nil
  end
  
  def feed_network_key
    post.feed_network_key
  end                        
end
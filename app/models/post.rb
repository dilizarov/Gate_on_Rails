class Post < ActiveRecord::Base
  include Externalable
  
  validates :user_id,     presence: true
  validates :network_id,  presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  after_create  :add_to_feed
  after_destroy :remove_from_feed
  after_destroy :delete_comments
  
  has_many :comments
  
  belongs_to :user
  belongs_to :network

  def add_to_feed
    num_of_posts = REDIS.hlen(feed_network_key)
    if num_of_posts > 30
      oldest_post = REDIS.hkeys(feed_network_key).min
      REDIS.hdel(feed_network_key, oldest_post)
    end
    REDIS.hset(feed_network_key, self.id, serialized_post(jsonified: true))
  end

  def remove_from_feed
    REDIS.hdel(feed_network_key, self.id)
  end
  
  # Essentially has_many :comments is dependent: destroy,
  # but I don't want to call the callback for deleting from feed
  # because it is pointless since the post just gets deleted from
  # feed taking the comments with it anyways
  def delete_comments
    self.comments.delete_all
  end
  
  def feed_network_key
    "network:#{self.network_id}:feed"
  end
  
  def feed_post_key
    "post:#{self.id}:comments"
  end
  
  def serialized_post(options = {})
    serialization = PostSerializer.new(self)
    options[:jsonified] ? serialization.to_json : serialization 
  end
end
  
class Comment < ActiveRecord::Base
  include Externalable

  validates :user_id,     presence: true
  validates :post_id,     presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  after_create :add_to_post!
  after_destroy :remove_from_post!
  
  belongs_to :user
  belongs_to :post
  
  
  def add_to_post!
    REDIS.lpush(feed_post_key, self.id)
  end
  
  def remove_from_post!
    REDIS.lrem(feed_post_key, 1, self.id)
  end
  
  def feed_post_key
    "post:#{self.post_id}:comments"
  end                        
end

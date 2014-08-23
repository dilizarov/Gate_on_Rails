class Post < ActiveRecord::Base
  include Externalable
  
  validates :user_id,     presence: true
  validates :network_id,  presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  after_create  :add_to_feed!
  after_destroy :remove_from_feed!
  
  has_many :comments, dependent: :destroy
  
  belongs_to :user
  belongs_to :network

  def add_to_feed!
    REDIS.lpush(feed_network_key, self.id)
  end
  
  def remove_from_feed!    
    REDIS.lrem(feed_network_key, 1, self.id)
  end
  
  def feed_network_key
    "network:#{self.network_id}:feed"
  end

end

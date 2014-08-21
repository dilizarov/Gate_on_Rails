class Post < ActiveRecord::Base
  include Externalable
  
  validates :user_id,     presence: true
  validates :network_id,  presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  after_create :add_to_feed!
  
  has_many :comments
  
  belongs_to :user
  belongs_to :network

  def add_to_feed!
    network_key = "network:#{self.network_id}:feed"
    serialized_post = PostSerializer.new(self).to_json
    
    REDIS.lpush(network_key, serialized_post)
    REDIS.ltrim(network_key, 0, MAX_NO_OF_POSTS_ON_REDIS - 1)
  end
end

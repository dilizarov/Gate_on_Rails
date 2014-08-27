class Network < ActiveRecord::Base
  include Externalable
  
  validates :name,       presence: true
  validates :creator_id, presence: true
  
  after_create :add_creator_to_network!
  
  has_many :users, 
           through: :user_networks
  
  has_many :user_networks, 
           class_name: "UserNetwork"
  
  has_many :posts
  
  belongs_to :creator, 
             class_name: "User",
             foreign_key: :creator_id
             
  def consolidate_feed_and_users
    # Serializing returns that Serializer object.
    # To get actual data, you need to use #to_json.
    # To get data back in ruby, must do JSON.parse.
    {
      network: {
        feed: feed,
        users: JSON.parse(serialized_users(jsonified: true))
      }
    }
  end
  
  def feed
    post_ids         = REDIS.hkeys(feed_network_key)
    ordered_post_ids = post_ids.sort.reverse
    serialized_posts = REDIS.hmget(feed_network_key, ordered_post_ids)
    
    serialized_posts.map { |serialized_post| JSON.parse(serialized_post) }
  end
  
  def serialized_users(options = {})
    serialization = ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer)
    options[:jsonified] ? serialization.to_json : serialization
  end
  
  def add_creator_to_network!
    UserNetwork.create(user_id: self.creator_id, network_id: self.id)
  end
  
  def feed_network_key
    "network:#{self.id}:feed"
  end
end


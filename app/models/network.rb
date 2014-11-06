class Network < ActiveRecord::Base
  include Externalable
  
  attr_accessor :num_of_users
  
  validates :name,       presence: true
  validates :creator_id, presence: true
  
  after_create :add_creator_to_network!
  
  has_many :users, 
           through: :user_networks
  
  has_many :user_networks, 
           class_name: "UserNetwork"
  
  has_many :posts, -> { order(created_at: :desc) }
  
  belongs_to :creator, 
             class_name: "User",
             foreign_key: :creator_id
  
  
  # Part of what *should be* a working REDIS feed implementation 
  # with comments and posts. Due to the $$ required for REDIS,
  # if we were to seriously use it, it is being saved for now.
  # We could return to it later. For now, we'll get the feed defacto
  # Rails style through the DB. 
  
  
  # def consolidate_feed_and_users
#     # Serializing returns that Serializer object.
#     # To get actual data, you need to use #to_json.
#     # To get data back in ruby, must do JSON.parse.
#     {
#       network: {
#         feed: feed,
#         users: JSON.parse(serialized_users(jsonified: true))
#       }
#     }
#   end
#
#   def feed
#     post_ids         = REDIS.hkeys(feed_network_key)
#     ordered_post_ids = post_ids.sort.reverse
#     serialized_posts = REDIS.hmget(feed_network_key, ordered_post_ids)
#
#     serialized_posts.map { |serialized_post| JSON.parse(serialized_post) }
#   end
#
#   def serialized_users(options = {})
#     serialization = ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer)
#     options[:jsonified] ? serialization.to_json : serialization
#   end
#
#   def feed_network_key
#     "network:#{self.id}:feed"
#   end

  private
  
  def add_creator_to_network!
    UserNetwork.create(user_id: self.creator_id, network_id: self.id)
  end

end


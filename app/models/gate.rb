class Gate < ActiveRecord::Base
  include Externalable
  
  attr_accessor :users_count
  
  validates :name,       presence: true
  validates :creator_id, presence: true
  
  after_create :add_creator_to_gate!
  
  has_many :users, 
           through: :user_gates
  
  has_many :user_gates, 
           class_name: "UserGate"
  
  has_many :posts, -> { order(created_at: :desc) }
  
  has_many :devices,
           through: :users
  
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
#       gate: {
#         feed: feed,
#         users: JSON.parse(serialized_users(jsonified: true))
#       }
#     }
#   end
#
#   def feed
#     post_ids         = REDIS.hkeys(feed_gate_key)
#     ordered_post_ids = post_ids.sort.reverse
#     serialized_posts = REDIS.hmget(feed_gate_key, ordered_post_ids)
#
#     serialized_posts.map { |serialized_post| JSON.parse(serialized_post) }
#   end
#
#   def serialized_users(options = {})
#     serialization = ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer)
#     options[:jsonified] ? serialization.to_json : serialization
#   end
#
#   def feed_gate_key
#     "gate:#{self.id}:feed"
#   end

  private
  
  def add_creator_to_gate!
    UserGate.create(user_id: self.creator_id, gate_id: self.id)
  end

end


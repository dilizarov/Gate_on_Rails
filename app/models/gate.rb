class Gate < ActiveRecord::Base
  include Externalable
  
  attr_accessor :users_count, :session
  
  validates :name,       presence: true
  validates :creator_id, presence: true
  
  # In place to prevent race conditions
  validates :external_id, uniqueness: true
  
  after_create :add_creator_to_gate!
  
  has_many :users,
           through: :user_gates
  
  has_many :user_gates, 
           class_name: "UserGate"
  
  has_many :posts,
           -> { order(created_at: :desc) },
           dependent: :destroy
  
  has_many :devices,
           through: :users
  
  belongs_to :creator, 
             class_name: "User",
             foreign_key: :creator_id
  
  def self.process_coords_for_gates!(lat, long)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    
    spots = client.spots(lat, long, radius: 50, exclude: ['accounting', 'atm', 'cemetery', 'finance', 'funeral_home', 'taxi_stand'])
  
    gates = []
  
    spots.select! { |spot| spot.types.include?("establishment") }
    
    spots.each do |spot|
      begin
        #creator_id required. Though, I suppose we could get rid of that at some point. Returns nil upon no creator, so shouldn't be an issue.
        gates << Gate.find_or_create_by(name: spot.name, external_id: spot.place_id, creator_id: 0, generated: true)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
    
    gates
  end
  
  def self.check_sessions!(gates, auth_token)
    auth_token = AuthenticationToken === auth_token ? auth_token : AuthenticationToken.where(token: auth_token).first
    
    user_gates = UserGate.where(user_id: auth_token.user_id, gate_id: gates.map(&:id), auth_token_id: auth_token.id)
    
    gates.each do |gate|
      next unless gate.generated
            
      gate.session = true unless user_gates.select { |user_gate| user_gate.gate_id == gate.id }.empty?
    end
    
    gates
  end
  
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
    if !(self.creator_id.nil? || self.creator_id == 0)
      UserGate.create(user_id: self.creator_id, gate_id: self.id)
    end
  end

end


class User < ActiveRecord::Base
  include Externalable
  
  acts_as_voter
  
  # Used in CurrentUser serializer
  attr_accessor :auth_token
  
  # Others available are:
  # :lockable, :timeoutable, :confirmable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates :name, presence: true
  
  has_many :gates,
           -> { order 'LOWER(gates.name)' },
           through: :user_gates
  
  has_many :user_gates,
           class_name: "UserGate"
           
  has_many :keys,
           foreign_key: :gatekeeper_id
  
  has_many :feed_posts,
           through: :gates,
           source: :posts
  
  has_many :posts
  has_many :comments
  has_many :devices
  has_many :authentication_tokens
  
  def gates_with_users_count(options = {})
    gates = self.gates
    
    gates = gates.includes(:creator) if options[:includes] == :creator
    
    # Gets the number of users in each gate that the user is in
    # { 24 => 11, 3 => 14, 1 => 1, 19 => 44} where the key is the gate id
    # and the value is the number of users.
  
    num_of_users_per_user_gate = UserGate.
         joins("INNER JOIN user_gates AS un ON user_gates.gate_id = un.gate_id").
         where("un.user_id = ?", self.id).
         group("user_gates.gate_id").
         count("user_gates.user_id")
  
    gates.each do |gate|
      gate.users_count = num_of_users_per_user_gate[gate.id]
    end
    
    gates
  end
  
  def grant_access(gates, user)
    
    # Filter out gates that other_user is already part of.
    gates_to_be_added = gates.map(&:id) - user.gates.map(&:id)
    
    user_gates = gates_to_be_added.map do |gate_id|
                      UserGate.new(user_id: user.id,
                                      gate_id: gate_id,
                                      gatekeeper_id: self.id)
                    end
    
    UserGate.import(user_gates)
  end
  
  def mark_uped_posts!(posts)
    uped_post_ids = self.find_up_votes_for_class(Post).where(votable_id: posts).map(&:votable_id)
    posts.each { |post| post.uped = uped_post_ids.include?(post.id) }
  end
  
  def mark_uped_comments!(comments)
    uped_comment_ids = self.find_up_votes_for_class(Comment).where(votable_id: comments).map(&:votable_id)
    comments.each { |comment| comment.uped = uped_comment_ids.include?(comment.id) }
  end
  
  # Takes a Gate object or gate id.
  def in_gate?(gate)
    gate_id = Gate === gate ? gate.id : gate
    !!UserGate.find_by(user_id: self.id, gate_id: gate_id)
  end
  
  # Takes an array of Gate objects or gate ids.
  # Implies based on type of first element.
  def in_gates?(gates)
    gate_ids = Gate === gates.first ? gates.map(&:id) : gates
    valid_gates = UserGate.where(user_id: self.id, 
                                       gate_id: gate_ids).pluck(:gate_id)
                                       
    (valid_gates & gate_ids).length == gate_ids.length
  end
  
  def owns_post?(post)
    self.id == post.user_id
  end
  
  def owns_comment?(comment)
    self.id == comment.user_id
  end
  
  def owns_key?(key)
    self.id == key.gatekeeper_id
  end
  
  def login!
    self.auth_token = AuthenticationToken.create(user_id: self.id).token
  end
  
  def logout!(auth_token)
    AuthenticationToken.where(token: auth_token).first.destroy
  end
  
  def sync_device(params)
    return if params[:token].nil? && params[:platform].nil?
    
    device = Device.find_or_initialize_by(token: params[:token])
    device.platform = params[:platform]
    device.user_id = self.id
    device.save
  end
  
  def unsync_device(params)
    return if params[:token].nil?
    
    device = Device.find_by(token: params[:token])
    if device && device.user_id == self.id
      device.destroy
    end
  end
end

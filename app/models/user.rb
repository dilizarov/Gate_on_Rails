class User < ActiveRecord::Base
  include Externalable
  
  acts_as_voter
  
  # Others available are:
  # :lockable, :timeoutable, :confirmable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
         
  before_save :ensure_authentication_token
  
  validates :name, presence: true
  
  has_many :networks,
           -> { order 'LOWER(networks.name)' },
           through: :user_networks
  
  has_many :user_networks,
           class_name: "UserNetwork"
           
  has_many :keys,
           foreign_key: :gatekeeper_id
  
  has_many :feed_posts,
           through: :networks,
           source: :posts
  
  has_many :posts
  has_many :comments
  has_many :devices
  
  def networks_with_users_count(options = {})
    networks = self.networks
    
    networks = networks.includes(:creator) if options[:includes] == :creator
    
    # Gets the number of users in each network that the user is in
    # { 24 => 11, 3 => 14, 1 => 1, 19 => 44} where the key is the network id
    # and the value is the number of users.
  
    num_of_users_per_user_network = UserNetwork.
         joins("INNER JOIN user_networks AS un ON user_networks.network_id = un.network_id").
         where("un.user_id = ?", self.id).
         group("user_networks.network_id").
         count("user_networks.user_id")
  
    networks.each do |network|
      network.users_count = num_of_users_per_user_network[network.id]
    end
    
    networks
  end
  
  def grant_access(networks, user)
    
    # Filter out networks that other_user is already part of.
    networks_to_be_added = networks.map(&:id) - user.networks.map(&:id)
    
    user_networks = networks_to_be_added.map do |network_id|
                      UserNetwork.new(user_id: user.id,
                                      network_id: network_id,
                                      gatekeeper_id: self.id)
                    end
    
    UserNetwork.import(user_networks)
  end
  
  def mark_uped_posts!(posts)
    uped_post_ids = self.find_up_votes_for_class(Post).where(votable_id: posts).map(&:votable_id)
    posts.each { |post| post.uped = uped_post_ids.include?(post.id) }
  end
  
  def mark_uped_comments!(comments)
    uped_comment_ids = self.find_up_votes_for_class(Comment).where(votable_id: comments).map(&:votable_id)
    comments.each { |comment| comment.uped = uped_comment_ids.include?(comment.id) }
  end
  
  # Takes a Network object or network id.
  def in_network?(network)
    network_id = Network === network ? network.id : network
    !!UserNetwork.find_by(user_id: self.id, network_id: network_id)
  end
  
  # Takes an array of Network objects or network ids.
  # Implies based on type of first element.
  def in_networks?(networks)
    network_ids = Network === networks.first ? networks.map(&:id) : networks
    valid_networks = UserNetwork.where(user_id: self.id, 
                                       network_id: network_ids).pluck(:network_id)
                                       
    (valid_networks & network_ids).length == network_ids.length
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

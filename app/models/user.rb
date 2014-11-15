class User < ActiveRecord::Base
  include Externalable
  
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
end

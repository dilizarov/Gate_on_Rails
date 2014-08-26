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
           through: :user_networks
  
  has_many :user_networks,
           class_name: "UserNetwork"
           
  has_many :keys,
           foreign_key: :gatekeeper_id
           
  has_many :posts
  has_many :comments
  
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
                                       network_id: network_ids)
                                       
    valid_networks.length == network_ids.length
  end
  
  def owns_post?(post)
    self.id == post.user_id
  end
  
  def owns_comment?(comment)
    self.id == comment.user_id
  end
end

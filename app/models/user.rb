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
  
  def in_network?(network)
    !!UserNetwork.find_by(user_id: self.id, network_id: network.id)
  end
  
  def owns_post?(post)
    self.id == post.user_id
  end
end

class User < ActiveRecord::Base
  include Externalable
  
  # Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :token_authenticatable
         
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
  
  def skip_confirmation!
    self.confirmed_at = Time.now
  end
end

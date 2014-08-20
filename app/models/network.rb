class Network < ActiveRecord::Base
  include Externalable

  validates :name,       presence: true
  validates :creator_id, presence: true
  
  has_many :users, 
           through: :user_networks
  
  has_many :user_networks, 
           class_name: "UserNetworks"
  
  belongs_to :creator, 
             class_name: "User",
             foreign_key: :creator_id
end

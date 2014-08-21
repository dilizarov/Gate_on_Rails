class Status < ActiveRecord::Base
  include Externalable
  
  validates :user_id,     presence: true
  validates :network_id,  presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  has_many :comments
  
  belongs_to :user
  belongs_to :network
end

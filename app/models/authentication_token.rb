class AuthenticationToken < ActiveRecord::Base

  before_create :set_authentication_token!
  
  validates :user_id, presence: true

  belongs_to :user

  def set_authentication_token!
    loop do
      candidate = Devise.friendly_token
      break self.token = candidate unless AuthenticationToken.where(token: candidate).first
    end
  end
  
end

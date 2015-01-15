class AuthenticationToken < ActiveRecord::Base
  belongs_to :user
  
  validates :token,   presence: true
  validates :user_id, presence: true

  before_create :set_authentication_token!

  private

  def set_authentication_token!
    loop do
      candidate = Devise.friendly_token
      break self.token = candidate unless self.class.unscoped.where(token: candidate).first
    end
  end
end

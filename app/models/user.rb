class User < ActiveRecord::Base
  # has external_id attribute
  include Externalable
  
  # Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :token_authenticatable
         
  before_save :ensure_authentication_token
  
  validates :name, presence: true
  
  def skip_confirmation!
    self.confirmed_at = Time.now
  end
end

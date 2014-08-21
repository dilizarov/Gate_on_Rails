class Comment < ActiveRecord::Base
  include Externalable

  validates :user_id,     presence: true
  validates :status_id,   presence: true
  validates :body,        presence: true,
                          length: { maximum: 500 }
  
  belongs_to :user
  belongs_to :status                        
end

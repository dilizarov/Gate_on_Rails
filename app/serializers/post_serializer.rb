class PostSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at
  
  has_one :user
  has_many :comments
end

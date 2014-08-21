class CommentSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at
  
  has_one :user
end

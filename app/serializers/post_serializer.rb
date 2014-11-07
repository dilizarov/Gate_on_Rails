class PostSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at, :comments_count
  
  has_one :user
  has_one :network, serializer: SimpleNetworkSerializer
end

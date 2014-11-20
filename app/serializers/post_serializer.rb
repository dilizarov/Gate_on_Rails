class PostSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at, :comments_count
  
  def attributes
    data = super
    data[:uped] = object.uped unless object.uped.nil?
    data
  end
  
  has_one :user
  has_one :network, serializer: SimpleNetworkSerializer
end

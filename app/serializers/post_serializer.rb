class PostSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at, :comments_count, :up_count, :image_url
  
  def attributes
    data = super
    data[:uped] = object.uped unless object.uped.nil?
    data
  end
  
  def image_url
    object.image and object.image.url
  end
  
  def up_count
    object.cached_votes_up
  end
  
  has_one :user
  has_one :gate, serializer: SimpleGateSerializer
end

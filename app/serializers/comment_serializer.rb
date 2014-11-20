class CommentSerializer < ActiveModel::Serializer
  attributes :external_id, :body, :created_at
  
  def attributes
    data = super
    data[:uped] = object.uped unless object.uped.nil?
    data
  end
  
  has_one :user
end

class SimpleNetworkSerializer < ActiveModel::Serializer
  attributes :name, :external_id
  
  def attributes
    data = super
    data[:num_of_users] = object.num_of_users unless object.num_of_users.nil?
    data
  end
  
  has_one :creator
end

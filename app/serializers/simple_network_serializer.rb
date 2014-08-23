class SimpleNetworkSerializer < ActiveModel::Serializer
  attributes :name, :external_id
  
  has_one :creator
end

class KeySerializer < ActiveModel::Serializer
  attributes :key, :networks
  
  def networks
    keys_networks = Network.where(id: object.networks).to_a
    ActiveModel::ArraySerializer.new(keys_networks, each_serializer: SimpleNetworkSerializer)
  end
end

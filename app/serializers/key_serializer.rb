class KeySerializer < ActiveModel::Serializer
  attributes :key, :gates
  
  def gates
    keys_gates = Gate.where(id: object.gates).to_a
    ActiveModel::ArraySerializer.new(keys_gates, each_serializer: SimpleGateSerializer)
  end
end

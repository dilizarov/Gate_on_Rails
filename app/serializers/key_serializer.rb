class KeySerializer < ActiveModel::Serializer
  attributes :key, :gates

  def key
    # 1234567891234567 turns into "1234-5678-9123-4567" for readability
    object.key.to_s.scan(/.{1,4}/).join("-")
  end
  
  def gates
    keys_gates = Gate.where(id: object.gates).to_a
    ActiveModel::ArraySerializer.new(keys_gates, each_serializer: SimpleGateSerializer)
  end
end

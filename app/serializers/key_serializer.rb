class KeySerializer < ActiveModel::Serializer
  attributes :key, :gates, :updated_at

  def key
    # 1234567890123456 turns into "1234-5678-9012-3456" for readability
    object.key.to_s.scan(/.{1,4}/).join("-")
  end
  
  def gates
    keys_gates = Gate.where(id: object.gates).to_a
    ActiveModel::ArraySerializer.new(keys_gates, each_serializer: SimpleGateSerializer).as_json
  end
end

class SimpleGateSerializer < ActiveModel::Serializer
  attributes :name, :external_id
  
  def attributes
    data = super
    data[:users_count] = object.users_count unless object.users_count.nil?
    data
  end
end

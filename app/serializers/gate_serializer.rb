class GateSerializer < ActiveModel::Serializer
  attributes :name, :external_id, :generated
  
  def attributes
    data = super
    data[:users_count] = object.users_count unless object.users_count.nil?
    data[:session] = object.session.nil? ? false : object.session
    data
  end
  
  has_one :creator
end

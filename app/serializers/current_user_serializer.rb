class CurrentUserSerializer < ActiveModel::Serializer
  attributes :name, :email, :external_id, :created_at
  
  def attributes
    data = super
    data[:auth_token] = object.auth_token unless object.auth_token.nil?
    data
  end 
end

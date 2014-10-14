class CurrentUserSerializer < ActiveModel::Serializer
  attributes :name, :email, :external_id, :created_at, :auth_token
  
  def auth_token
    object.authentication_token
  end
end

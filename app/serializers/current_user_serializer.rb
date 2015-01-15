class CurrentUserSerializer < ActiveModel::Serializer
  attributes :name, :email, :external_id, :created_at, :auth_token
end

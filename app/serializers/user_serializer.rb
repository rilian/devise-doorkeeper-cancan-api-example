class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :is_admin, :created_at, :updated_at
end

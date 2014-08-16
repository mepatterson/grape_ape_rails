class MonkeySerializer < ActiveModel::Serializer
  attributes :name, :color, :description, :created_at

  def description
    "#{object.name} is #{object.color} and was born on #{object.created_at}."
  end
end

class Widget < ActiveRecord::Base

  validates_presence_of :name, :color
  validates_inclusion_of :color, in: %w[ red green blue orange ]

end

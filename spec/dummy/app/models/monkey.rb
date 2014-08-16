class Monkey < ActiveRecord::Base
  validates_presence_of :name, :color
end

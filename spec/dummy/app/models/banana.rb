class Banana < ActiveRecord::Base
  validates_presence_of :size
  belongs_to :monkey
end

class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :name
      t.string :color
      t.boolean :radioactive, default: false
      t.integer :rads, default: 0
    end
  end
end

class CreateMonkeys < ActiveRecord::Migration
  def change
    create_table :monkeys do |t|
      t.string :name
      t.string :color
      t.timestamps
    end
  end
end

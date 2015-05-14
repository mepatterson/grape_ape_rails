class CreateBananas < ActiveRecord::Migration
  def change
    create_table :bananas do |t|
      t.string :size
      t.references :monkey
    end
  end
end

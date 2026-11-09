class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.belongs_to :menu, null: false, foreign_key: true
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :menu_items, :uuid, unique: true
  end
end

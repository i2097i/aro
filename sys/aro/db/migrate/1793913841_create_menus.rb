class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :menus, :uuid, unique: true
  end
end

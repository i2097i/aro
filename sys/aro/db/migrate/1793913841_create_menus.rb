class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.string :i18n_display_key, null: false
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :menus, :i18n_display_key, unique: true
  end
end

class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.belongs_to :menu, null: false, foreign_key: true
      t.string :uuid, null: false
      t.string :i18n_display_key, null: false
      t.string :tty_name

      t.timestamps
    end

    add_index :menu_items, [:menu_id, :tty_name], unique: true
  end
end

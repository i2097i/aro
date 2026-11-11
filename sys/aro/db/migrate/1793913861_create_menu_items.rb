# frozen_string_literal: true

class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.belongs_to :menu, null: false, foreign_key: true
      t.string :uuid, null: false
      t.integer :type_flag, default: 1

      t.timestamps
    end

    add_index :menu_items, :uuid, unique: true
  end
end

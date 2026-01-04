class CreateScrolls < ActiveRecord::Migration[8.1]

  def self.up
    create_table :scrolls do |t|
      t.belongs_to :legend, null: false, foreign_key: true
      t.belongs_to :player, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cards, null: false, default: ""

      t.timestamps
    end

    add_index :scrolls, :name
  end

  def self.down
    drop_table :scrolls
  end

end

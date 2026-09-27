class CreatePlayers < ActiveRecord::Migration[8.1]

  def self.up
    create_table :players do |t|
      t.belongs_to :scroll, null: false, foreign_key: true
      t.integer :you_id, null: false

      t.timestamps
    end

    add_index :players, :you_id
  end

  def self.down
    drop_table :players
  end

end

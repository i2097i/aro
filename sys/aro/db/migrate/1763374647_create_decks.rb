class CreateDecks < ActiveRecord::Migration[8.1]

  def self.up
    create_table :decks do |t|
      t.string :name
      t.string :cards, null: false, default: ""
      t.string :drawn, null: false, default: ""

      t.timestamps
    end

    add_index :decks, :name, unique: true
  end

  def self.down
    remove_index :decks, :name
    drop_table :decks
  end

end

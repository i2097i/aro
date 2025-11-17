class CreateDecks < ActiveRecord::Migration[8.1]

  def self.up
    create_table :decks do |t|
      t.string :name
      t.string :cards

      t.timestamps
    end
  end

  def self.down
    drop_table :decks
  end

end

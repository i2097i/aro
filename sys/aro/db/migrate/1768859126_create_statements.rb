class CreateStatements < ActiveRecord::Migration[8.1]

  def self.up
    create_table :statements do |t|
      t.belongs_to :player, null: false, foreign_key: true
      t.belongs_to :chapter, null: false, foreign_key: true

      # all cards in the statement except the word
      t.string :thought, null: false, default: ""

      # the final card that must be played to close the statement
      t.string :word, null: false, default: ""

      t.timestamps
    end
  end

  def self.down
    drop_table :statements
  end

end

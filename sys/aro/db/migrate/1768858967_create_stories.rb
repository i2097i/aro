class CreateStories < ActiveRecord::Migration[8.1]

  def self.up
    create_table :stories do |t|
      t.belongs_to :legend, null: false, foreign_key: true
      t.belongs_to :chapter, null: false, foreign_key: true
      t.belongs_to :dealer, null: false, foreign_key: true

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end

end

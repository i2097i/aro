class CreateChapters < ActiveRecord::Migration[8.1]

  def self.up
    create_table :chapters do |t|
      t.belongs_to :story, null: false, foreign_key: true

      t.timestamps
    end
  end

  def self.down
    drop_table :chapters
  end

end

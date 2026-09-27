class CreateLegends < ActiveRecord::Migration[8.1]

  def self.up
    create_table :legends do |t|
      t.belongs_to :story, null: false, foreign_key: true
      t.integer :play_to, null: false, default: Aro::Mancy::NUMERALS[:XI]

      t.timestamps
    end
  end

  def self.down
    drop_table :legends
  end

end

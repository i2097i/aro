class CreateYous < ActiveRecord::Migration[8.1]

  def self.up
    create_table :yous do |t|
      t.string :name, null: false
      t.string :pwd
      t.integer :access, default: Aro::Mancy::S

      t.timestamps

      t.index :name, unique: true
    end
  end

  def self.down
    remove_index :yous, :name
    drop_table :yous
  end

end

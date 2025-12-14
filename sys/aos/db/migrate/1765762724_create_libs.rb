class CreateLibs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :libs do |t|
      t.string :name, null: false
      t.string :so_path, null: false
      t.integer :status, default: Aro::Mancy::O

      t.timestamps

      t.index :name, unique: true
      t.index :so_path, unique: true
    end
  end

  def self.down
    remove_index :libs, :name
    remove_index :libs, :so_path
    drop_table :libs
  end

end

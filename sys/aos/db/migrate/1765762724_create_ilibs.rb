class CreateIlibs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :ilibs do |t|
      t.string :name, null: false
      t.string :so_path, null: false
      t.integer :status, default: Aro::Mancy::O

      t.timestamps

      t.index :name, unique: true
      t.index :so_path, unique: true
    end
  end

  def self.down
    remove_index :ilibs, :name
    remove_index :ilibs, :so_path
    drop_table :ilibs
  end

end

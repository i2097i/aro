class CreateTecks < ActiveRecord::Migration[8.1]

  def self.up
    create_table :tecks do |t|
      t.string :name
      t.string :cards, null: false, default: ""
      t.string :drawn, null: false, default: ""

      t.timestamps
    end

    add_index :tecks, :name, unique: true
  end

  def self.down
    remove_index :tecks, :name
    drop_table :tecks
  end

end

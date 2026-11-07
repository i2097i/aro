class CreateDataBases < ActiveRecord::Migration[8.1]
  def change
    create_table :data_bases do |t|
      t.string :unix_path, null: false
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :data_bases, :uuid, unique: true
    add_index :data_bases, :unix_path, unique: true
  end
end

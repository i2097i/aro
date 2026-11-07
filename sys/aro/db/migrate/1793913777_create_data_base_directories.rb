class CreateDataBaseDirectories < ActiveRecord::Migration[8.1]
  def change
    create_table :data_base_directories do |t|
      t.string :unix_path, null: false
      t.belongs_to :data_base, null: false, foreign_key: true
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :data_base_directories, :uuid, unique: true
    add_index :data_base_directories, [:data_base_id, :unix_path], unique: true
  end
end

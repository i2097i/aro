class CreateDataBaseFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :data_base_files do |t|
      t.belongs_to :data_base_directory, null: false, foreign_key: true
      t.string :uuid, null: false

      t.timestamps
    end
  end
end

class CreateLogs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :logs do |t|
      t.string :data

      t.timestamps
    end

    add_column :logs, :deck_id, :integer
    add_index :logs, :deck_id
  end

  def self.down
    drop_table :logs
  end

end

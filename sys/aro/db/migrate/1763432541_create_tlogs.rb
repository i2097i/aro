class CreateTlogs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :tlogs do |t|
      t.string :card_data
      t.string :drawn_data

      t.timestamps
    end

    add_column :tlogs, :teck_id, :integer
    add_index :tlogs, :teck_id
  end

  def self.down
    remove_index :tlogs, :teck_id
    drop_table :tlogs
  end

end

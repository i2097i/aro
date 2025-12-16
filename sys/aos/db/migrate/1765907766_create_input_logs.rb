class CreateInputLogs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :input_logs do |t|
      t.belongs_to :you, null: false, foreign_key: true
      t.string :cmd, null: false
      t.string :pwd, null: false

      t.timestamps
    end
  end

  def self.down
    remove_index :input_logs, :pwd
    drop_table :input_logs
  end

end

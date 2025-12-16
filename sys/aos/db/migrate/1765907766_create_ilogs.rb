class CreateIlogs < ActiveRecord::Migration[8.1]

  def self.up
    create_table :ilogs do |t|
      t.belongs_to :you, null: false, foreign_key: true
      t.string :cmd, null: false
      t.string :pwd, null: false

      t.timestamps
    end
  end

  def self.down
    remove_index :ilogs, :pwd
    drop_table :ilogs
  end

end

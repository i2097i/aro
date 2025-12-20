class CreateFpxys < ActiveRecord::Migration[8.1]

  def self.up
    create_table :fpxies do |t|
      t.belongs_to :you, null: false, foreign_key: true
      t.string :cmd, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :fpxies
  end

end

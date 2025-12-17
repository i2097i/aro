class CreateAgodos < ActiveRecord::Migration[8.1]

  def self.up
    create_table :agodos do |t|
      t.integer :power, default: Aro::Mancy::O
      t.belongs_to :you, null: false, foreign_key: true
      t.string :home
      t.string :go, null: false
      t.string :do, null: false, default: ""

      # rate is commands-per-minute (default 1)
      t.integer :rate, default: Aro::Mancy::S

      t.timestamps
    end
  end

  def self.down
    drop_table :agodos
  end

end

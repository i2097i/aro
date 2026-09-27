=begin

  scroll.rb

  scroll object.

  by i2097i

=end

class Aro::Scroll < ActiveRecord::Base

  HISTORY_FILE = :".ino_history"

  has_many :players
  belongs_to :legend
  belongs_to :player

  before_create :create_history_file, :create_legend

  def history_file
    File.join(Aro::Db.base_aro_dir, Aro::Scroll::HISTORY_FILE.to_s)
  end

  def history
    File.read(history_file).split("\n").compact
  end

  def add_history(entry)
    return if entry.nil? || entry.to_s.empty?
    File.open(history_file, "a+") do |ino_history|
      ino_history.write(entry)
      ino_history.write("\n")
    end
  end

  private

  def create_legend
    self.legend = Aro::Legend.create()
  end

  def create_history_file
    File.open(history_file, "w+")
  end
end

=begin

  data.rb

  aro dom table.

  by i2097i

=end

class Aro::Dom::DataBase::Directory < ActiveRecord::Base
  include Aro::Dom::Uuid
  self.table_name = :data_base_directories
  belongs_to :data_base, class_name: "Aro::Dom::DataBase"

  has_many :data_base_files, class_name: "Aro::Dom::DataBase::File"

  after_create :sync
  after_commit :sync

  def ensure_unix_exists!
    unless Dir.exist?(aro_directory_path)
      Aro::P.say("creating #{Aro::Dom::DataBase::Directory} for #{aro_directory_path}")
      FileUtils.mkdir(aro_directory_path)
      ::File.write(File.join(aro_directory_path, ".uuid"), uuid)
    end
  end

  def aro_directory_path
    ::File.join(data_base.aro_data_base_path, unix_path)
  end

  private

  def sync
    Aro::Dom::Ma_ain.instance.data_mutex.synchronize do
      ensure_unix_exists!
    end
  end
end
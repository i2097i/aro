=begin

  row.rb

  aro dom data file.

  by i2097i

=end

class Aro::Dom::DataBase::File < ActiveRecord::Base
  include Aro::Dom::Uuid
  self.table_name = :data_base_files
  belongs_to :data_base_directory, class_name: "Aro::Dom::DataBase::Directory"

  def write!(updates)
    Aro::Dom::Store.edit(self, updates)
  end

  def aro_file_path
    ::File.join(
      data_base_directory.aro_directory_path,
      "#{uuid}.json"
    )
  end

end

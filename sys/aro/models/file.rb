=begin

  row.rb

  aro dom data file.

  by i2097i

=end

class Aro::Dom::DataBase::File < ActiveRecord::Base
  include Aro::Dom::Uuid
  belongs_to :data_base_directory, class_name: "Aro::Dom::DataBase::Directory"


end
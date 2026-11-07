=begin

  menu.rb

  aro dom menu.

  by i2097i

=end

class Aro::Dom::Menu < ActiveRecord::Base
  include Aro::Dom::Uuid

  has_many :menu_items, class_name: "Aro::Dom::MenuItem"

  def localized_name
    I18n.t(full_i18n_path)
  end

  def full_i18n_path
    "#{self.class.table_name}.#{uuid}"
  end

  def directory
    Aro::Dom::DataBase::Directory.find_by(uuid: uuid)
  end
end
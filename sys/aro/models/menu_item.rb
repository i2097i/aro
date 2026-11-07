=begin

  menu.rb

  aro dom menu item.

  by i2097i

=end

class Aro::Dom::MenuItem < ActiveRecord::Base
  include Aro::Dom::Uuid
  belongs_to :menu, class_name: "Aro::Dom::Menu"

  after_create :sync

  def as_tty
    {name: localized_name, value: uuid}
  end

  def localized_name
    I18n.t(full_i18n_path)
  end

  def full_i18n_path
    "#{self.class.table_name}.#{uuid}"
  end

  def aro_directory
    return if menu.nil?
    Aro::Dom::DataBase::Directory.find_by(uuid: menu.uuid)
  end

  def aro_file
    return if aro_directory.nil?
    Aro::Dom::DataBase::File.find_or_create_by(
      uuid: uuid,
      data_base_directory: aro_directory
    )
  end

  private

  def sync
    Aro::Dom::DataBase.sync_menu_item(self)
  end
end
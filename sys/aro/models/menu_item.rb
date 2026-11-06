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
    I18n.t(i18n_display_key)
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
    if tty_name.to_sym == :noop
      Aro::Dom::Designer.design_menu_item(self)
    else
      Aro::Dom::DataBase.sync_menu_item(self)
    end
  end
end
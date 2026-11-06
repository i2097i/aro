=begin

  menu.rb

  aro dom menu.

  by i2097i

=end

class Aro::Dom::Menu < ActiveRecord::Base
  include Aro::Dom::Uuid

  has_many :menu_items, class_name: "Aro::Dom::MenuItem"

  after_create :ensure_empty_item_exists

  def localized_name
    I18n.t(i18n_display_key)
  end

  def valid_values
    ma_ain_menu.menu_items.map{|mi| mi.uuid}
  end

  def directory
    Aro::Dom::DataBase::Directory.find_by(uuid: uuid)
  end

  private

  def ensure_empty_item_exists
    return unless menu_items.empty?

    # first menu option opens database designer by default
    menu_items.create(tty_name: :noop, i18n_display_key: "menu_items.noop")
  end
end
=begin

  menu.rb

  aro dom menu.

  by i2097i

=end

require_relative :"./concerns/uuid".to_s

class Aro::Dom::Menu < ActiveRecord::Base
  include Aro::Dom::Uuid

  has_many :menu_items, class_name: "Aro::Dom::MenuItem"

  def title
    I18n.t(i18n_display_key)
  end

  def valid_values
    ma_ain_menu.menu_items.map{|mi| mi.tty_value}
  end
end
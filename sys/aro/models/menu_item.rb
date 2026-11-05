=begin

  menu.rb

  aro dom menu item.

  by i2097i

=end

class Aro::Dom::MenuItem < ActiveRecord::Base
  include Aro::Dom::Uuid
  belongs_to :menu, class_name: "Aro::Dom::Menu"

  def as_tty
    {name: tty_name, value: tty_value}
  end
end
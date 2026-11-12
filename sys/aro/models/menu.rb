# frozen_string_literal: true

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

  def generate_new_item(localized_name, for_type: :user)
    new_menu_item = new_menu_item&.to_s
    new_menu_item = menu_items.create(type_flag: for_type)
    Aro::Dom::DataBase.sync_menu_item!(new_menu_item, localized_name)
    new_menu_item
  end

  def rename_item(menu_item, new_name)
    raise "invalid menu item!" unless !menu_item.nil? &&
      self.menu_items.include?(menu_item)

    Aro::Dom::DataBase.sync_menu_item!(menu_item, new_name)
  end

  def generate_ma_ain!
    return unless is_menu_named?(:ma_ain) &&
      menu_items.empty?

    [:library, :settings, :quit].each{|k|
      i = generate_new_item(k, for_type: :system)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          Aro::Dom::Ma_ain,
          "exec_#{k}!",
          k
        )
      )
    }
  end

  def generate_settings!
    return unless is_menu_named?(:settings) &&
      menu_items.empty?

    [:cor, :git, :ssh].each{|k|
      i = generate_new_item(k, for_type: :system)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          Aro::Dom::Oss_OpenMenu,
          "open_#{k}!",
          k
        )
      )
    }
  end

  def generate_user_default!
    return unless menu_items.empty?
    generate_new_item(I18n.t("open_menu.default_user_item_text", localized_name: localized_name))
  end

  private

  def is_menu_named?(name_sym)
    name_sym = name_sym&.to_sym

    !directory.nil? &&
      directory.unix_path.to_sym == name_sym
  end
end
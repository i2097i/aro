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

  def generate_new_item(new_item_name)
    new_menu_item = new_menu_item&.to_s
    new_menu_item = menu_items.create
    Aro::Dom::Locale.add_i18n_key(
      new_item_name,
      library_name: :menu_items,
      new_i18n_display_key: new_menu_item.uuid,
    )
    new_menu_item
  end

  def generate_ma_ain!
    return unless is_menu_named?(:ma_ain) &&
      menu_items.empty?

    [:security, :quit].each{|k|
      i = generate_new_item(k)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          Aro::Dom::Ma_ain,
          "exec_#{k}!",
          label: k
        )
      )
    }
  end

  def generate_security!
    return unless is_menu_named?(:security) &&
      menu_items.empty?

    [:git, :ssh].each{|s|
      k = "#{s}_config"
      i = generate_new_item(k)

      i.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          Aro::Dom::Oss_OpenMenu,
          "open_#{k}",
          label: k
        )
      )
    }
  end

  def generate_ssh_config!
    return unless is_menu_named?(:ssh_config) &&
      menu_items.empty?


    # [].each{|s|
    #   k = "#{s}_config"
    #   i = generate_new_item(k)

    #   i.aro_file.write!(
    #     Aro::Dom::Store.build_exec_oss_om_params!(
    #       Aro::Dom::Oss_OpenMenu,
    #       "open_#{k}",
    #       label: k
    #     )
    #   )
    # }
  end

  def generate_git_config!

  end

  def is_menu_named?(name_sym)
    name_sym = name_sym&.to_sym

    !directory.nil? &&
      directory.unix_path.to_sym == name_sym
  end
end
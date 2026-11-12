# frozen_string_literal: true

=begin

  data.rb

  aro dom data.

  by i2097i

=end

class Aro::Dom::DataBase < ActiveRecord::Base
  include Aro::Dom::Uuid
  self.table_name = :data_bases

  has_many :data_base_directories, class_name: "Aro::Dom::DataBase::Directory"

  after_commit :sync

  def self.open_menu(menu_sym)
    # get the menu directory
    @@data_base_directory = menu_data_base.data_base_directories.find_or_create_by(
      unix_path: menu_sym
    )

    menu = Aro::Dom::Menu.find_by(uuid: @@data_base_directory.uuid)
    if menu.nil?
      # find or create the new menu
      menu = Aro::Dom::Menu.create(uuid: @@data_base_directory.uuid)
      Aro::Dom::Locale.add_i18n_key(
        menu_sym.to_s,
        new_i18n_display_key: menu.uuid
      )
    end

    generate_menu_items_for!(menu)

    # return the menu
    return menu
  end

  def self.menu_data_base
    Aro::Dom::DataBase.find_or_create_by(unix_path: Aro::Dom::Menu.table_name)
  end

  def self.sync_menu_item!(menu_item, localized_name)
    raise "missing menu_item!" unless !menu_item.nil? &&
      menu_item.kind_of?(Aro::Dom::MenuItem)

    Aro::Dom::Locale.update_i18n_key(
      localized_name,
      menu_item.uuid,
      library_name: :menu_items
    )

    # set up by system menus
    return true if menu_item.system?

    # ensure default menu_item.aro_file exists
    # for user-created menu items
    menu_item.aro_file.write!(
      Aro::Dom::Store.build_exec_oss_om_params!(
        Aro::Dom::Oss_OpenMenu,
        :name, # defaults to Aro::Dom::Oss_OpenMenu.name
        menu_item.localized_name
      )
    )
  end

  def self.ensure_data_base_exist!
    unless Dir.exist?(root_aro_unix_data_dir)
      Aro::P.say(__method__)
      Aro::P.say("creating #{root_aro_unix_data_dir}")
      FileUtils.mkdir(root_aro_unix_data_dir)
      ensure_data_base_git!
    end
  end


  def self.ensure_data_base_git!
    ensure_data_base_exist! unless Dir.exist?(root_aro_unix_data_dir)
  end

  def unix_path_valid?
    unix_path.kind_of?(String) && !unix_path.empty?
  end

  def aro_data_base_path
    ::File.join(Aro::Dom::DataBase.root_aro_unix_data_dir, unix_path)
  end

  def self.root_aro_unix_data_dir
    ::File.join(Aro::Mancy.root_dir, table_name)
  end

  def ensure_unix_exists!
    raise "unix_path invalid! #{(unix_path)}" unless unix_path_valid?
    unless Dir.exist?(aro_data_base_path)
      Aro::P.say(__method__)
      Aro::P.say("creating #{aro_data_base_path}")
      FileUtils.mkdir(aro_data_base_path)
      ::File.write(::File.join(aro_data_base_path, ".uuid"), uuid)
    end
  end

  private

  def self.generate_menu_items_for!(menu)
    raise "invalid menu!" if menu.nil?

    case @@data_base_directory.unix_path.to_sym
    when :ma_ain
      menu.generate_ma_ain!
    when :settings
      menu.generate_settings!
    when :library
      generate_items!(menu, Aro::Dom::Library)
    when :git
      generate_items!(menu, Aro::Dom::Git)
    when :ssh
      generate_items!(menu, Aro::Dom::Ssh)
    else
      menu.generate_user_default!
    end
  end

  def self.generate_items!(menu, oss_om_const_for_exec)
    return unless !menu.nil? && menu.menu_items.empty?
    raise "invalid directory! #{@@data_base_directory}" if @@data_base_directory.nil? ||
      @@data_base_directory.uuid != menu.uuid
    raise "invalid const! #{oss_om_const_for_exec}" unless Aro::Dom::Oss_OpenMenu::EXEC_CLASSES.include?(
        oss_om_const_for_exec.name
      ) && oss_om_const_for_exec::EXEC_METHODS.kind_of?(Array) &&
      oss_om_const_for_exec::EXEC_METHODS.all?{|em|
        oss_om_const_for_exec.methods.include?(em.to_sym)
      }
    
    oss_om_const_for_exec::EXEC_METHODS.each{|method_name|
      menu_item = menu.generate_new_item(method_name, for_type: :system)

      menu_item.aro_file.write!(
        Aro::Dom::Store.build_exec_oss_om_params!(
          oss_om_const_for_exec,
          method_name,
          "#{@@data_base_directory.unix_path} #{method_name}"
        )
      )
    }
  end

  def sync
    Aro::Dom::Ma_ain.instance.data_mutex.synchronize do
      self.class.ensure_data_base_git!
      ensure_unix_exists!
    end
  end

end
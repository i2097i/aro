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
    data_base_directory = menu_data_base.data_base_directories.find_or_create_by(
      unix_path: menu_sym
    )

    menu = Aro::Dom::Menu.find_by(uuid: data_base_directory.uuid)
    if menu.nil?
      # find or create the new menu
      menu = Aro::Dom::Menu.create(uuid: data_base_directory.uuid)
      Aro::Dom::Locale.add_i18n_key(
        menu_sym.to_s,
        new_i18n_display_key: menu.uuid
      )
    end

    case menu_sym
    when :ma_ain
      # nothing to do here yet
      menu.generate_ma_ain!
    when :security
      # todo:
      menu.generate_security!
    end

    # return the menu
    return menu
  end

  def self.menu_data_base
    Aro::Dom::DataBase.find_or_create_by(unix_path: Aro::Dom::Menu.table_name)
  end

  def self.sync_menu_item(menu_item)
    # todo:
    puts "todo: #{__method__} #{menu_item.inspect}"
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
    # FileUtils.chdir(root_aro_unix_data_dir) do
    #   Aro::P.say("todo:")
    #   Aro::P.say(__method__)
    #   # system("git init")
    # end
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

  def sync
    Aro::Dom::Ma_ain.instance.data_mutex.synchronize do
      self.class.ensure_data_base_git!
      ensure_unix_exists!
    end
  end
end
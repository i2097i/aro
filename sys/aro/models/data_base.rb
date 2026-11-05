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
    # load menu data
    menus_data_base = Aro::Dom::DataBase.find_or_create_by(unix_path: Aro::Dom::Menu.table_name)
    menus_data_base.data_base_directories.where(
      uuid: Dir[::File.join(menus_data_base.aro_data_base_path, "*")].select{|d| Dir.exist?(d)}.map{|d| ::File.basename(d)}
    )

    if menus_data_base.data_base_directories.empty?
      menus_data_base.data_base_directories.create(unix_path: menu_sym)
      # todo: create files here
    end
  end

  def self.ensure_data_base_exist!
    unless Dir.exist?(table_name)
      Aro::P.say(__method__)
      Aro::P.say("creating #{table_name}")
      FileUtils.mkdir(table_name)
      ensure_data_base_git!
    end
  end


  def self.ensure_data_base_git!
    ensure_data_base_exist! unless Dir.exist?(table_name)
    FileUtils.chdir table_name do
      # todo:
      # system("git init")
    end
  end

  def unix_path_valid?
    unix_path.kind_of?(String) && !unix_path.empty?
  end

  def aro_data_base_path
    ::File.join(self.class.table_name, unix_path)
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
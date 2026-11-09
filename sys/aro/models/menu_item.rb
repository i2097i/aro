=begin

  menu.rb

  aro dom menu item.

  by i2097i

=end

class Aro::Dom::MenuItem < ActiveRecord::Base
  include Aro::Dom::TarGoForRootSec
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

  def actionable?
    !action_storage_key.nil?
  end

  def action_storage_key
    return @ask unless @ask.nil?
    action_typedef_key = store.get_key("action_key")&.to_sym
    unless Aro::Dom::Action::TYPES.select{|k, v| v[:key] == action_typedef_key}.any?
      raise "missing or invalid #{__method__}! (#{action_typedef_key})"
    end

    @ask = action_typedef_key.to_s&.gsub("exec_", "")&.upcase&.to_sym
    @ask
  end

  def store
    Aro::Dom::Ma_ain.instance.get_store_for(aro_file)
  end

  def run!
    unless action_storage_key.nil?
      Aro::Dom::Action.perform(
        Aro::Dom::Action::TYPES.keys.select{|k|
          k == action_storage_key
        }.first,
        store.get_key("action_params")
      )
    else
      Aro::Dom::Ma_ain.i2097i_bookmark
      puts __method__
      puts inspect
      puts :todo_implement_invalid_action_handling
    end
  end

  private

  def sync
    Aro::Dom::DataBase.sync_menu_item(self)
  end
end
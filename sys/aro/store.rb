# frozen_string_literal: true

=begin

  store.rb

  json data store

  by i2097i

=end

class Aro::Dom::Store
  attr_accessor :is_open, :cache, :clear_flag, :parser_error, :open_file_path

  def initialize
    open_file_path = nil
    clear_cache!
  end

  def clear_cache!
    if @is_open
      @clear_flag = true
      return
    end
    @clear_flag = false
    @is_open = false

    @cache = {} # clear'd
  end

  def self.edit(aro_file, updates)
    return if aro_file.nil?
    unless ::File.exist?(aro_file.aro_file_path)
      ::File.write(aro_file.aro_file_path, {}.to_json)
    end

    Aro::Dom::Ma_ain.i2097i_bookmark
    puts :todo_validate_updates_or_depricate
    puts __method__

    # Aro::Dom::Ma_ain.instance.store_mutex.synchronize do
      store_instance = Aro::Dom::Ma_ain.instance.get_store_for(aro_file)
      updates.each{|k, v|

        store_instance.save_key_value_pair(k, v)
        Aro::P.say([
          "reading in #{k} after setting to #{v} in #{aro_file.aro_file_path}",
          "got value => #{store_instance.safe_get_key(k)}"
        ])
      }
    # end
  end

  def save_key_value_pair(k, v)
    set_key(k, v)
  end

  def save_exec_oss_om_params!(oss_om_const, oss_om_method, label)
    Aro::P.say(__method__)
    Aro::Dom::Ma_ain.instance.store_mutex.synchronize do
      built = self.class.build_exec_oss_om_params!(oss_om_const, oss_om_method, label)
      built.each{|k, v| self.set_key(k, v)}
    end
  end

  def self.build_exec_oss_om_params!(oss_om_const, oss_om_method, label)
    Aro::P.say(__method__)
    # {
    #   action_name:,
    #   action_key: Aro::Dom::Action::TYPES[:OSS_OM][:key],
    #   action_params: {
    #     aro_class_name:,
    #     aro_class_method:
    #   }
    # }
    raise "invalid oss_om_const!" unless Aro::Dom::Oss_OpenMenu::EXEC_CLASSES.include?(oss_om_const)
    raise "invalid oss_om_method!" unless oss_om_const.methods.include?(oss_om_method.to_sym)
    {
      action_name: label,
      action_key: :exec_oss_om,
      action_params: {
        aro_class_name: oss_om_const.name,
        aro_class_method: oss_om_method
      }
    }
  end

  def safe_get_key(k)
    safe_key = nil
    Aro::Dom::Ma_ain.instance.store_mutex.synchronize do
      safe_key = get_key(k)
    end

    safe_key
  end

  private

  def get_key(key)
    return if open_file_path.nil?

    key = key.to_s

    # ensure default for key exists
    @cache[key] = {value: nil, persisted: false} unless @cache.keys.include?(key)

    # return cache value if storage open or the cache value is persisted
    return @cache[key][:value] if @is_open || @cache[key][:persisted]

    # open storage
    @is_open = true
    storage_contents = {}
    @parser_error = Aro::Dom::Ssh.decrypt_file!(open_file_path)
    unless @parser_error.kind_of?(StandardError) ||
      StandardError.subclasses.include?(@parser_error.class)

      # return value from Aro::Dom::Ssh.decrypt_file!
      # is not an error.
      storage_contents = @parser_error
      @parser_error = nil
    end

    unless @parser_error.nil?
      @is_open = false
      raise @parser_error
    end

    # only update the cache value if present in storage
    if storage_contents.keys.include?(key)
      @cache[key] = {value: storage_contents[key], persisted: true}
    else
      @cache[key][:persisted] = false
    end

    value = @cache[key][:value]
    @is_open = false
    clear_cache! if @clear_flag

    return value
  end

  def set_key(key, value)
    return if open_file_path.nil?

    key = key.to_s

    # ensure default for key exists
    @cache[key] = {value: value, persisted: false} unless @cache.keys.include?(key)

    # assign new cache value and set persisted to false
    @cache[key][:value] = value
    @cache[key][:persisted] = false

    # return if storage open
    # non-persisted cache values update next cycle
    return true if @is_open

    # open storage
    @is_open = true
    storage_contents = {}

    @parser_error = Aro::Dom::Ssh.decrypt_file!(open_file_path)
    unless @parser_error.kind_of?(StandardError) ||
      StandardError.subclasses.include?(@parser_error.class)

      # return value from Aro::Dom::Ssh.decrypt_file!
      # is not an error.
      storage_contents = @parser_error
      @parser_error = nil
    end

    unless @parser_error.nil?
      @is_open = false
      raise @parser_error
    end

    # update storage and cache
    ([key] + @cache.keys.select{|k|
      !@cache[k][:persisted]
    }).each{|k|
      storage_contents[k] = @cache[k][:value]
      @cache[k][:persisted] = true
    }

    # write storage
    write_result = Aro::Dom::Ssh.write_encrypted_file!(open_file_path, storage_contents.to_json)
    unless write_result == true
      @is_open = false
      raise write_result
    end

    # close storage
    @is_open = false
    clear_cache! if @clear_flag

    write_result
  end
end

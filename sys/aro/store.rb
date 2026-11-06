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
      ::File.write(aro_file.aro_file_path, "{}")
    end

    # todo: validate updates
    Aro::Dom::Ma_ain.instance.store_mutex.synchronize do
      store_instance = Aro::Dom::Ma_ain.instance.get_store_for(aro_file)
      updates.each{|k, v|
        store_instance.set_key(k, v)
        Aro::P.say([
          "reading in #{k} after setting to #{v} in #{aro_file.aro_file_path}",
          "got value => #{store_instance.get_key(k)}"
        ])
      }
    end
  end

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
    begin
      @parser_error = nil
      # read storage
      storage_contents = JSON.parse(
        ::File.read(open_file_path, encoding: "UTF-8")
      )
    rescue StandardError => e
      @is_open = false
      if @parser_error.nil?
        @parser_error = e
        return get_key(key)
      else
        raise @parser_error
      end
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
    return if @is_open

    # open storage
    @is_open = true
    storage_contents = {}
    begin
      @parser_error = nil
      # read storage
      storage_contents = JSON.parse(
        ::File.read(open_file_path, encoding: "UTF-8")
      )
    rescue StandardError => e
      @is_open = false
      if @parser_error.nil?
        @parser_error = e
        return get_key(key)
      else
        raise @parser_error
      end
    end

    # update storage and cache
    ([key] + @cache.keys.select{|k|
      !@cache[k][:persisted]
    }).each{|k|
      storage_contents[k] = @cache[k][:value]
      @cache[k][:persisted] = true
    }

    # write storage
    ::File.open(open_file_path, "w+") do |f|
      f.write(storage_contents.to_json)
    end

    # close storage
    @is_open = false
    clear_cache! if @clear_flag
  end
end

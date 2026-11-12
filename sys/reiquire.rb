# frozen_string_literal: true

=begin
  
  reiquire.rb

  ruby require helpers.

  by i2097i

=end

module Reiquire
  def self.aro

    # ensure i18n is initialized
    initialize_i18n!

    # require runtime dependencies
    require_dependencies!

    # require aro library
    require_reiquires!

    # configure locale
    configure_i18n

    require_relative "./ma_ain"
  end

  def self.requires(dirs)
    dirs.each{|d|
      Dir[
        File.join(__dir__, d.to_s, :"**/**/*.rb".to_s)
      ].each { |f| require f }
    }
  end

  def self.reload_i18n!
    copy_locale_files_from_gem!
    configure_i18n
  end

  def self.gem_migrations_path
    File.join(gem_dir, :"sys/aro/db".to_s)
  end

  def self.gem_locale_dir
    File.join(gem_dir, :locale.to_s)
  end

  def self.gem_locales_filepaths
    File.join(gem_locale_dir, "*.yml")
  end

  private


  def self.require_dependencies!
    [
      :active_record,
      :"active_record/schema_dumper",
      :fileutils,
      :"tty-font",
      :"tty-prompt"
    ].each{|d| require d.to_s}
  end


  def self.copy_locale_files_from_gem!
    Aro::D.say(__method__)
    return if Aro::Cor.ivar(:OSS_OM_HOME).nil? || oss_om_up_to_date?(
      gem_locales_filepaths,
      Aro::Dom::Locale.locales_filepaths
    )

    file_utils_wtf = File.join(Aro::Mancy.root_dir, :locale.to_s, :locale.to_s)
    if Dir.exist?(file_utils_wtf)
      FileUtils.rm_rf(file_utils_wtf)
      oss_om_up_to_date!(
        gem_locales_filepaths,
        Aro::Dom::Locale.locale_dir
      )
      return
    end

    FileUtils.mkdir_p(Aro::Dom::Locale.locale_dir)
    FileUtils.cp_r(
      gem_locale_dir,
      Aro::Dom::Locale.locale_dir
    )
  end

  def self.oss_om_up_to_date!(gem_filepaths, oss_om_dir)
    Aro::D.say(__method__)
    gem_files_abs = Dir[gem_filepaths].map{|fp| File.absolute_path(fp)}
    Aro::D.say("gem_files_abs: #{gem_files_abs}")
    
    Aro::D.say("FileUtils.mkdir_p(#{oss_om_dir})")
    FileUtils.mkdir_p(oss_om_dir)
    gem_files_abs.each{|gfa|
      Aro::D.say("FileUtils.cp(#{File.basename(gfa)}, #{File.basename(oss_om_dir)})")
      FileUtils.cp(gfa, oss_om_dir)
    }
  end

  def self.oss_om_up_to_date?(gem_filepaths, oss_om_filepaths)
    Aro::P.say(__method__)
    file_names = Dir[oss_om_filepaths].map{|fp| File.basename(fp)}
    Aro::D.say("file_names: #{file_names}")
    gem_file_names = Dir[gem_filepaths].map{|fp| File.basename(fp)}
    Aro::D.say("gem_file_names: #{gem_file_names}")
    up_to_date = gem_file_names.all?{|gfn|
      file_names.include?(gfn)
    }
    Aro::P.say("up_to_date: #{up_to_date}")
    up_to_date
  end

  def self.require_reiquires!
    # require sys folders
    Reiquire::requires([:shr, :aro])
  end

  def self.gem_dir
    Dir[
      Gem.loaded_specs[Aro.to_s.downcase]&.full_gem_path
    ].first
  end

  def self.initialize_i18n!
    require :i18n.to_s
    aro_i18n_library = File.join(gem_dir, :locale.to_s, "*.yml")
    I18n.load_path += Dir[aro_i18n_library]
    I18n.available_locales = [:en]
    I18n.default_locale = :en
    I18n.reload!
  end

  def self.configure_i18n
    gem_dir_variable = gem_dir
    copy_locale_files_from_gem!
    aro_i18n_library = File.join(gem_dir_variable, :locale.to_s, "*.yml")
    if Aro::Mancy.is_initialized?
      I18n.load_path = I18n.load_path.select{|lp|
        # stop using gem locales if in_aro?
        !gem_dir_variable.include?(lp)
      }
      aro_i18n_library = File.join(Aro::Dom::Locale.locale_dir, "*.yml")
    end
    I18n.load_path += Dir[aro_i18n_library]
    I18n.available_locales = [:en]
    I18n.default_locale = :en
  end

end
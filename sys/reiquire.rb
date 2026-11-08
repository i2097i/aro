=begin
  
  reiquire.rb

  ruby require helpers.

  by i2097i

=end

module Reiquire
  def self.aro
    # require runtime dependencies
    require_dependencies!

    # require aro library
    require_reiquires!

    # configure locale
    configure_i18n

    # ensure base migrations exist
    copy_db_migrations_from_gem! if Aro::Mancy.in_aro?
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

  def self.copy_db_migrations_from_gem!
    puts __method__
    puts Aro::Cor.ivar(:OSS_OM_HOME)
    return if Aro::Cor.ivar(:OSS_OM_HOME).nil? || oss_om_up_to_date?(
      Aro::Db.gem_migrations_filepaths,
      Aro::Db.migrations_filepaths
    )

    FileUtils.mkdir_p(Aro::Db.migrate_dir)
    FileUtils.cp_r(
      gem_migrations_path,
      Aro::Db.migrate_dir
    )
  end

  private

  def self.copy_locale_files_from_gem!
    puts __method__
    puts Aro::Cor.ivar(:OSS_OM_HOME)
    return if Aro::Cor.ivar(:OSS_OM_HOME).nil? || oss_om_up_to_date?(
      gem_locales_filepaths,
      Aro::Dom::Locale.locales_filepaths
    )

    oss_wtf = File.join(Aro::Mancy.root_dir, :locale.to_s, :locale.to_s)
    if Dir.exist?(oss_wtf)
      FileUtils.rm_rf(oss_wtf)
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
    puts __method__
    gem_files_abs = Dir[gem_filepaths].map{|fp| File.absolute_path(fp)}
    puts "gem_files_abs: #{gem_files_abs}"
    
    puts "FileUtils.mkdir_p(#{oss_om_dir})"
    FileUtils.mkdir_p(oss_om_dir)
    gem_files_abs.each{|gfa|
      puts "FileUtils.cp(#{File.basename(gfa)}, #{File.basename(oss_om_dir)})"
      FileUtils.cp(gfa, oss_om_dir)
    }
  end

  def self.oss_om_up_to_date?(gem_filepaths, oss_om_filepaths)
    puts __method__
    file_names = Dir[oss_om_filepaths].map{|fp| File.basename(fp)}
    puts "file_names: #{file_names}"
    gem_file_names = Dir[gem_filepaths].map{|fp| File.basename(fp)}
    puts "gem_file_names: #{gem_file_names}"
    mfs_all = gem_file_names.all?{|gfn|
      file_names.include?(gfn)
    }
    puts "mfs_all: #{mfs_all}"
    mfs_all
  end

  def self.require_reiquires!
    # require sys folders
    Reiquire::requires([:shr, :aro, :cli])

    # require cli module
    require_relative :"./cli".to_s
  end

  def self.require_dependencies!
    [
      :active_record,
      :"active_record/schema_dumper",
      :fileutils,
      :i18n,
      :"tty-prompt"
    ].each{|d| require d.to_s}
  end

  def self.gem_dir
    Dir[
      Gem.loaded_specs[Aro.to_s.downcase]&.full_gem_path
    ].first
  end

  def self.configure_i18n
    Aro::D.say(__method__)
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
    Aro::D.say("I18n.load_path")
    Aro::D.say(I18n.load_path)
    Aro::D.say("I18n.available_locales")
    Aro::D.say(I18n.available_locales)
    Aro::D.say("I18n.default_locale")
    Aro::D.say(I18n.default_locale)
    Aro::D.say("I18n.reload!")
    Aro::D.say(I18n.reload!)
  end

end
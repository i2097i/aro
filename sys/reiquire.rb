=begin
  
  reiquire.rb

  ruby require helpers.

  by i2097i

=end

module Reiquire
  GEM_MIGRATIONS_PATH = :"sys/aro/db"

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

  def self.copy_db_migrations_from_gem!
    FileUtils.cp_r(
      File.join(gem_dir, GEM_MIGRATIONS_PATH.to_s),
      Aro::Mancy.root_dir
    ) unless Dir.exist?(Aro::Db.local_migrate_dir)
  end

  private

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

  def self.copy_locale_files_from_gem!
    return unless Aro::Mancy.in_aro?
    Aro::D.say(__method__)
    FileUtils.cp_r(
      File.join(gem_dir, :locale.to_s),
      Aro::Mancy.root_dir
    ) unless Dir.exist?(Aro::Dom::Locale.locale_dir)
  end

  def self.gem_dir
    Dir[
      Gem.loaded_specs[Aro.to_s.downcase]&.full_gem_path
    ].first
  end

  def self.configure_i18n
    Aro::D.say(__method__)
    copy_locale_files_from_gem!
    aro_i18n_library = File.join(gem_dir, :locale.to_s, "*.yml")
    if Aro::Mancy.in_aro?
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
  end

end
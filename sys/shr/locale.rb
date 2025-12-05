=begin
  
  locale.rb

  localization configuration.

  by i2097i

=end

require :i18n.to_s

module Aro
  LOCALE_DIR = :locale

  locale_path = Gem.loaded_specs[:aro.to_s]&.full_gem_path
  if Aro::IS_TEST.call
    locale_path = Dir.pwd
  end
  I18n.load_path += Dir["#{locale_path}/#{LOCALE_DIR}/*.yml"]
  I18n.available_locales = [:en]
  I18n.default_locale = :en
end
=begin
  
  locale.rb

  localization configuration.

  by i2097i

=end

require :i18n.to_s
require :aro.to_s

module Aro
  LOCALE_DIR = :locale

  def self.init_i18n
    locale_path = Gem.loaded_specs[:aro.to_s]&.full_gem_path
    Aro::D.say("Aro::Mancy.is_test?: #{Aro::Mancy.is_test?}")
    if Aro::Mancy.is_test?
      locale_path = Dir.pwd
    end
    I18n.load_path += Dir["#{locale_path}/#{Aro::LOCALE_DIR}/*.yml"]
    I18n.available_locales = [:en]
    I18n.default_locale = :en
  end
end
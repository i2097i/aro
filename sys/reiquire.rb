=begin
  
  reiquire.rb

  ruby require helpers.

  by i2097i

=end

# dependencies
require :active_record.to_s
require :"active_record/schema_dumper".to_s
require :base64.to_s
require :ffi.to_s
require :fileutils.to_s
require :"io/console".to_s
require :i18n.to_s
require :readline.to_s
require :"tty-prompt".to_s
require :yaml.to_s

module Reiquire
  GEM_PATH = Gem.loaded_specs[:aro.to_s]&.full_gem_path

  def self.aro
    # configure I18n

    I18n.load_path += Dir["#{Reiquire::GEM_PATH}/locale/*.yml"]
    I18n.available_locales = [:en]
    I18n.default_locale = :en    

    # require sys folders
    Reiquire::requires([:shr, :aro, :dom, :cli, :aos])

    # require cli module
    require_relative :"./cli".to_s
  end

  def self.requires(dirs)
    dirs.each{|d|
      Dir[
        File.join(__dir__, d.to_s, :"**/*.rb".to_s)
      ].each { |f| require f}
    }
  end
end
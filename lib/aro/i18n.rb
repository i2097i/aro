# frozen_string_literal: true

require :i18n.to_s

module Aro
  # ...
end

locale_path = Gem.loaded_specs[:aro.to_s]&.full_gem_path
if Aro::IS_TEST.call
  locale_path = Dir.pwd
end
I18n.load_path += Dir["#{locale_path}/locale/*.yml"]
I18n.default_locale = :en

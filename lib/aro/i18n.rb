# frozen_string_literal: true

require :i18n.to_s

module Aro
  # ...
end

I18n.load_path += Dir["#{Gem.loaded_specs[:aro.to_s]&.full_gem_path}/locale/*.yml"]
I18n.default_locale = :en
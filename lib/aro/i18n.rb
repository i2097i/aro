# frozen_string_literal: true

require :i18n.to_s

module I18n
  # ...
end

I18n.load_path += Dir["#{Dir.pwd}/locale/*.yml"]
I18n.default_locale = :en
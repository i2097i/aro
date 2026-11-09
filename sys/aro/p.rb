=begin
  
  p.rb

  p logger for aro space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s
require_relative :"./r".to_s

module Aro
  class P < Aro::Prompt

    def self.say(message)
      if Aro::Dom::Ma_ain.instance.nil? &&
        Aro::Mancy.in_aro? &&
        !Aro::T.is_dev_tarot?

        Aro::R.say(normalize_message(message))
      else
        super("#{Aro::Dom::Ma_ain.ps1_display || Aro::Mancy.ps1_display}#{normalize_message(message)}")
      end
    end

    def self.default_select(display_text, options)
      Aro::P.p.select(
        Aro::Dom::Ma_ain.mini_hud_for(display_text),
        options,
        show_help: :always,
        cycle: true,
        per_page: 11
      )
    end

  end
end


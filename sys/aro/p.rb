=begin
  
  p.rb

  p logger for aro space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class P < Aro::Prompt

    def self.say(message)
      super("#{Aro::Dom::Ma_ain.ps1_display || Aro::Mancy.ps1_display}#{normalize_message(message)}")
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


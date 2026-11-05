=begin
  
  r.rb

  r logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class R < Aro::Prompt
    def self.say(message)
      super("#{Aro::Mancy.ps1_display(Aro::R.name)} #{normalize_message(message)}")
    end
  end
end


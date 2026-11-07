=begin
  
  d.rb

  d logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s
require :aro.to_s

module Aro
  class D < Aro::Prompt
    def self.say(message)
      return unless Aro::D.should_print?

      super("#{Aro::Mancy.ps1_display(Aro::D.name)}#{normalize_message(message)}")
    end

    def self.should_print?
      return false unless Aro::Cor.ivar(:ENV).present?
      Aro::Cor::DBG_MODES.include?(Aro::Cor.ivar(:ENV)&.to_sym)
    end
  end
end


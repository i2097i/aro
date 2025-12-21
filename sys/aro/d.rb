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
      super([">[#{Aro::Mancy::I2097I}]>: #{message}"])
    end

    def self.should_print?
      return false unless Aos::Cor.ivar(:ENV).present?
      Aos::Cor::DBG_MODES.include?(Aos::Cor.ivar(:ENV)&.to_sym)
    end
  end
end


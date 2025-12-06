=begin
  
  aro_d.rb

  logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class D < Aro::Prompt
    def self.say(message)
      return unless Aro::Mancy::ARO_ENV_DEBUG_MODES.include?(ENV[:ARO_ENV.to_s])
      Aro::P::p.say(">[#{Aro::Mancy::I2097I}]>: #{message}\n")
    end
  end
end


=begin
  
  d.rb

  d logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class D < Aro::Prompt
    def self.say(message)
      return unless Aro::D.should_print?
      Aro::P::p.say(">[#{Aro::Mancy::I2097I}]>: #{message}\n")
    end

    def self.should_print?
      Aro::Mancy::ARO_ENV_DEBUG_MODES[Aro::Mancy::O].to_s == ENV[:ARO_ENV.to_s]
    end
  end
end


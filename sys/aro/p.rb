=begin
  
  aro_p.rb

  logger for aro space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class P < Aro::Prompt
    def self.say(message)
      Aro::P::p.say(">[#{Aro::Mancy::PS1}]>: #{message}")
    end
  end
end


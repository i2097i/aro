=begin
  
  dom_p.rb

  logger for dom space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class Dom::P < Aro::Prompt
    def self.say(message)
      Aro::Dom::P.p.say(">[#{Aro::Dom::PS1}]>: #{message}")
    end
  end
end

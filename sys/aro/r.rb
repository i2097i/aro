=begin
  
  r.rb

  r logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class R < Aro::Prompt
    def self.say(message)
      Aro::P::p.say(">[#{Aro::T::RUBY_FACOT}]>: #{message}\n")
    end
  end
end


=begin

  s.rb

  s logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aos
  class S < Aro::Prompt
    def self.say(message)
      return unless Aos::S.should_print?
      Aro::P::p.say(message)
    end

    def self.should_print?
      true
    end
  end
end


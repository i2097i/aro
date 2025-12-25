=begin
  
  r.rb

  r logger for i2097i.

  by i2097i

=end

require_relative :"../shr/prompt".to_s

module Aro
  class R < Aro::Prompt
    PS1 = :">[#{Aro::T::RUBY_FACOT}]>:"
    def self.say(message)
      super(["#{Aro::R::PS1} #{message}"])
    end
  end
end


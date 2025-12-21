=begin
  
  p.rb

  p logger for aro space.

  by i2097i

=end

require_relative :"../shr/prompt".to_s
require_relative :"./r".to_s

module Aro
  class P < Aro::Prompt
    def self.say(message)
      if Aro::Mancy.in_aro? && !Aro::T.is_dev_tarot?
        Aro::R.say(message)
      else
        super(["#{Aro::Mancy::PS1}#{message}"])
      end
    end
  end
end


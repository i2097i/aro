=begin
  
  p.rb

  p logger for dom space.

  by i2097i

=end

module Aro
  class Dom::P < Aro::Prompt
    def self.say(message)
      super(["#{Aro::Dom::PS1}#{message}"])
    end
  end
end

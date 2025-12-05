=begin
  
  prompt.rb

  base logger for aro.

  by i2097i

=end

require :"tty-prompt".to_s

module Aro
  class Prompt
    include Singleton

    attr_accessor :prompt

    def initialize
      self.prompt = TTY::Prompt.new
    end

    def self.p
      P.instance.prompt
    end

    def self.say(message)
      raise :override_me.to_s
    end

    def self.less(display_text = "")
      IO.popen("less -X", "w") { |f| f.puts display_text }
    end
  end
end

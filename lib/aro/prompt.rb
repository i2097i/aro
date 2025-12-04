require :"tty-prompt".to_s

module Aro
  class P
    include Singleton

    attr_accessor :prompt

    def initialize
      self.prompt = TTY::Prompt.new
    end

    def self.p
      P.instance.prompt
    end

    def self.say(message)
      Aro::P::p.say(">[#{Aro::Mancy::PS1}::#{Time.now.to_i}]>: #{message}")
    end

    def self.less(display_text = "")
      IO.popen("less -X", "w") { |f| f.puts display_text }
    end
  end
end

=begin

  prompt.rb

  base logger for aro.

  by i2097i

=end

module Aro
  class Prompt
    include Singleton

    attr_accessor :prompt

    def initialize
      self.prompt = TTY::Prompt.new
    end

    def self.p
      Aro::Prompt.instance.prompt
    end

    def self.should_print?
      Aro::Config::BOOLS[:TRUE]
    end

    def self.say(message)
      raise :override_me.to_s
    end

    def self.less(message)
      IO.popen("less -X", "w") { |f| f.puts(message) }
    end
  end
end

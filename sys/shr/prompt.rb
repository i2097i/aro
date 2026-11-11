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
      Aro::Cor::BOOLS[:TRUE]
    end

    def self.ask(message)
      gets message
    end

    def self.say(message)
      p.say(normalize_message(message))
    end

    def self.less(message)
      IO.popen("less -X", "w") { |f| f.puts(message) }
    end

    def self.normalize_message(message)
      return message.join("\n") if message.kind_of?(Array)
      message
    end
  end
end

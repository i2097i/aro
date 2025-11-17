require 'tty-prompt'

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
  end
end
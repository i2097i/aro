=begin
  
  v.rb

  v logger for i2097i.

  by i2097i

=end

require_relative :d.to_s

module Aro
  class V < Aro::D
    def self.say(message)
      return unless Aro::V.should_print?
      Aro::P::p.say(">[VERBOSE]>: #{message}\n")
    end

    def self.should_print?
      CLI::Config.ivar(:VERBOSE).to_s == CLI::Config::BOOLS[:TRUE].to_s && super
    end
  end
end


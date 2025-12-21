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
      super(message)
    end

    def self.should_print?
      Aos::Cor.ivar(:VERBOSE).to_s == Aos::Cor::BOOLS[:TRUE].to_s && super
    end
  end
end

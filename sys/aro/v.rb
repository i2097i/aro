# frozen_string_literal: true

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
      super(normalize_message(message))
    end

    def self.should_print?
      Aro::Cor.ivar(:VERBOSE).to_s == Aro::Cor::BOOLS[:TRUE].to_s
    end
  end
end

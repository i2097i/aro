=begin
  
  views/base.rb

  the base view (abstract).

  by i2097i

=end

require :aro.to_s

module Aro
  module Vi
    class Base
      def self.generate(model)
        CLI::Nterface.exit_error_invalid_usage!
      end

      def self.draw(model)
        CLI::Nterface.exit_error_invalid_usage!
      end

      def self.debug_log(model)
        Aro::V.say(model)
      end
    end
  end
end
=begin

  views/games/abpps.rb

  the apbbs view.

  by i2097i

=end

require_relative :"./game".to_s

module Aos
  module Vi
    class Abpps < Aos::Vi::Game
      def self.show(model)
        draw(super, model)
      end
    end
  end
end
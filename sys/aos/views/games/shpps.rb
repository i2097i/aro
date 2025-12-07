=begin

  views/games/shpps.rb

  the shbbs view.

  by i2097i

=end

require_relative :"./game".to_s

module Aos
  module Vi
    class Shpps < Aos::Vi::Game
      def self.show(model)
        draw(super, model)
      end
    end
  end
end
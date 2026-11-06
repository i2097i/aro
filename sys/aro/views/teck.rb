=begin

  vws/games/game.rb

  the game view.

  by i2097i

=end

require_relative :"../models/teck".to_s
require_relative :"./base".to_s

module Aro
  module Views
    class Teck < Aro::Views::Base

      def self.show
        if Aro::Mancy.teck.nil?
          draw(["no teck loaded...exiting..."])
          return
        end

        Aro::P.say(:"Aro::Dom::Ma_ain.run".to_s)
        draw(Aro::Dom::Ma_ain.run)
      end

    end
  end
end
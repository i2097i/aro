=begin

  views/games/game.rb

  the game view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vi
    class Game < Aos::Vi::Base
      def self.show(model)
        lines = []
        lines << I18n.t("aos.views.game.title").center(viewport_width)
        lines << I18n.t("aos.views.game.description").center(viewport_width)
        lines
      end
    end
  end
end
=begin

  vws/games/abot.rb

  the abot view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Abot < Aos::Vw::Base
      def self.show
        draw(Aos::Abot.instance.display_lines)
      end
    end
  end
end

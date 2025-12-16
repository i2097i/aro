=begin

  vws/root/amg.rb

  the amg view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Amg < Aos::Vw::Base
      def self.show
        draw(Aos::Amg.instance.display_lines)
      end
    end
  end
end
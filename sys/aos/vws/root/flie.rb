=begin

  vws/root/flie.rb

  the flie view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Flie < Aos::Vw::Base
      def self.show
        draw(Aos::Flie.instance.display_lines)
      end
    end
  end
end

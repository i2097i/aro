=begin
  
  vws/root/cor.rb

  the cor view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Cor < Aos::Vw::Base
      def self.show
        draw(Aos::Cor.instance.display_lines)
      end
    end
  end
end
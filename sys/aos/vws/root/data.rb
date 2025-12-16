=begin

  vws/root/data.rb

  the data view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Data < Aos::Vw::Base
      def self.show
        draw(Aos::Data.instance.display_lines)
      end
    end
  end
end

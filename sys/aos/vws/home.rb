=begin

  vws/root/home.rb

  the home view.

  by i2097i

=end

require_relative :"./base".to_s

module Aos
  module Vw
    class Home < Aos::Vw::Base
      def self.show
        if Aos::Os.instance.you.home?
          draw(Aro::Config.instance.display_lines)
        end
      end
    end
  end
end
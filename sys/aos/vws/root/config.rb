=begin
  
  vws/root/config.rb

  the config view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Config < Aos::Vw::Base
      def self.show
        draw(Aro::Config.instance.display_lines)
      end
    end
  end
end
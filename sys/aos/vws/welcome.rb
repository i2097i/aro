=begin

  vws/welcome.rb

  the welcome view.

  by i2097i

=end

require_relative :"./base".to_s

module Aos
  module Vw
    class Welcome < Aos::Vw::Base
      def self.show
        lines = []

        dc = Aro::Config.display_configuration
        height = dc[:HEIGHT]
        width = dc[:WIDTH]


        lines << "welcome to #{Aro::Dom.ethergeist_name}".center(width)
        lines << ""
        yous = Aos::You.where(access: [:agodo, :user])
        lines << "there are no users" if yous.empty?
        yous.each{|y|
          lines += y.get_lines
        }
        draw(lines)
      end
    end
  end
end
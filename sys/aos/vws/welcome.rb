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
        hwidth = width - (Aos::Vw::Base::MARGIN_H * Aro::Mancy::OS)
        lines << "".ljust(hwidth, dc[:DIVIDER])
        lines << "map".center(hwidth)
        lines << "".ljust(hwidth, dc[:DIVIDER])
        lines << ""
        yous = Aos::You.where(pwd: Aro::Dom.dom_root)
        dom_line = "#{Aro::Dom.ethergeist_name}"
        dom_line += (yous.any? ? " [#{yous.map{|y| y.name}.join(" ")}]" : "")
        lines << dom_line
        Aro::Dom::D::LAYOUT.values.each{|wing|
          yous = Aos::You.where(pwd: File.join(Aro::Dom.dom_root, wing[:name].to_s))
          wing_line = "".ljust(Aro::Mancy::NUMERALS[:IV])
          wing_line += wing[:name].to_s
          wing_line += (yous.any? ? " [#{yous.map{|y| y.name}.join(" ")}]" : "")
          lines << wing_line
          wing[:rooms].each{|room|
            yous = Aos::You.where(pwd: File.join(Aro::Dom.dom_root, Aro::Dom.room_path(room[:name])))
            room_line = "".ljust(Aro::Mancy::NUMERALS[:VIII])
            room_line += room[:name].to_s
            room_line += (yous.any? ? " [#{yous.map{|y| y.name}.join(" ")}]" : "")
            lines << room_line
          }
        }
        lines << ""

        yous = Aos::You.order(access: :desc).all
        if yous.empty?
          lines << "no yous."
        else
          lines << "".ljust(hwidth, dc[:DIVIDER])
          lines << "roster".center(hwidth)
          lines << "".ljust(hwidth, dc[:DIVIDER])
          lines << ""
          yous.each{|y|
            lines += y.get_lines.map{|l| l.center(hwidth)}
          }
        end
        draw(lines)
      end
    end
  end
end
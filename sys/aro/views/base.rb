=begin
  
  views/base.rb

  the base view (abstract).

  by i2097i

=end

module Aro
  module Views
    class Base
      BAR = :"".to_s
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show
        draw([
          "the #{self.name} room."
        ])
      end

      def self.draw(body_lines)
        return false unless body_lines.kind_of?(Array)
        lines = []

        dc = Aro::Cor.discon
        width = dc[:WIDTH]

        if Aro::Dom.in_aro_dom?
          lines += get_main_divider(width, true)
        end

        # top vertical margin
        Aro::Views::Base::MARGIN_V.times do
          lines << get_body_line("")
        end

        # yield => print lines
        body_lines.each{|line|
          lines << get_body_line(line)
        }

        # print everything

        Aro::Prompt.say(lines)

        # explicitly return true
        true
      end

      def self.get_main_divider(width, clock = false)
        left = "#{Aro::Mancy::PS1}"
        if clock
          left = "#{left}#{get_domain} >"
        else
          left = "#{left}v#{Aro::VERSION} >"
        end
        right = "< " + (clock ? get_clock : get_display_dimension.strip)
        lines = []
        lines << ""
        lines << left.ljust(width - right.length, "-".to_s) + right
        lines << ""
        lines
      end

      def self.get_display_dimension
        "#{Aro::T.read_dev_tarot(true).rjust(Aro::Mancy::V)} :<[#{self.get_dimension}]<"
      end

      def self.get_dimension
        (Aro::T.is_dev_tarot? ? Aro::T::DEV_TAROT : Aro::T::RUBY_FACOT)
      end

      def self.get_domain
        Aro::Mancy.in_aro? ? Aro::Mancy.domain : Aro::Dom.domain
      end

      def self.get_clock
        Time.now.strftime(Aro::Mancy::DATE_FORMAT)
      end

      def self.viewport_width
        dc = Aro::Cor.discon
        width = dc[:WIDTH]
        bar_width = (Aro::Views::Base::BAR.length * Aro::Mancy::OS)
        h_margin_width = (Aro::Views::Base::MARGIN_H * Aro::Mancy::OS)

        (width - (bar_width + h_margin_width))
      end

      def self.get_body_line(line)
        hm = Aro::Views::Base::MARGIN_H
        bar = Aro::Views::Base::BAR
        hm_space = " " * Aro::Views::Base::MARGIN_H
        just = Aro::Cor.discon[:WIDTH] - (hm_space.length + bar.length)
        (bar + hm_space + (line || "")).ljust(just) + hm_space + bar
      end

    end
  end
end
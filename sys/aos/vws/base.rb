=begin
  
  vws/base.rb

  the base view (abstract).

  by i2097i

=end

module Aos
  module Vw
    class Base
      BAR = :"".to_s
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show
        draw([
          "the #{self.name} room.",
          "",
          "getting directory listing...",
          "",
          Aos::Os.instance.get_ls([])
        ])
      end

      def self.draw(body_lines)
        return false unless body_lines.kind_of?(Array)
        lines = []

        dc = Aos::Cor.discon
        width = dc[:WIDTH]

        if Aro::Dom.in_arodom?
          lines += get_main_divider(width, true)
        end

        # top vertical margin
        Aos::Vw::Base::MARGIN_V.times do
          lines << get_body_line("")
        end

        # yield => print lines
        body_lines.each{|line|
          lines << get_body_line(line)
        }

        if Aro::Dom.in_arodom?
          lines += get_aos_display_lines
        end

        # print everything

        Aro::Prompt.say(lines)

        # explicitly return true
        true
      end

      def self.get_main_divider(width, clock = false)
        left = "#{Aos::Os::PS1}"
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

      def self.get_aos_display_lines
        # current Aos::Os output

        width = Aos::Cor.discon[:WIDTH]
        lines = []
        Aos::Db.load

        the_you = Aos::Os.instance.you_flag || Aos::Os.instance.you
        Aro::V.say(Aos::Os.you_name_from_flag_arg)
        Aro::V.say(the_you.inspect)
        present_users = Aos::You.order(
          name: :asc
        ).where(
          pwd: the_you.pwd,
          access: [:agodo, :user]
        ).map{|y|
          (the_you == y ? Aos::Os::STAR.to_s : "") +
          y.name
        }

        if present_users.any?
          lines << "[ yous in the room ]".center(width)
          lines << ("[  " + present_users.join("    ") + "  ]").center(width)
        end
        lines << ":you_are_root".center(width) if the_you.root?
        Aos::Os.instance.display_lines ||= []
        unless Aos::Os.instance.display_lines.empty?
          lines << ""
          Aos::Os.instance.display_lines.each{|line|
            lines << line
          }
          Aos::Os.instance.display_lines = []
          lines << ""
        end
        lines += get_main_divider(width)
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
        Time.now.strftime(Aos::Os::DATE_FORMAT)
      end

      def self.viewport_width
        dc = Aos::Cor.discon
        width = dc[:WIDTH]
        bar_width = (Aos::Vw::Base::BAR.length * Aro::Mancy::OS)
        h_margin_width = (Aos::Vw::Base::MARGIN_H * Aro::Mancy::OS)

        (width - (bar_width + h_margin_width))
      end

      def self.get_body_line(line)
        hm = Aos::Vw::Base::MARGIN_H
        bar = Aos::Vw::Base::BAR
        hm_space = " " * Aos::Vw::Base::MARGIN_H
        just = Aos::Cor.discon[:WIDTH] - (hm_space.length + bar.length)
        (bar + hm_space + (line || "")).ljust(just) + hm_space + bar
      end

      def self.lines_for_cmd(cmd)
        just_cmds = Aro::Mancy::NUMERALS[:IX]
        lines = []
        lines << "\"#{cmd[:key]}\""
        lines << "  => #{cmd[:description]}"
        lines << ""
        lines << "#{"  ".rjust(just_cmds)} #{cmd[:usage]}"
        lines << ""
        lines
      end
    end
  end
end
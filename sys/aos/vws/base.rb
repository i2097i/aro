=begin
  
  vws/base.rb

  the base view (abstract).

  by i2097i

=end

module Aos
  module Vw
    class Base
      BAR = :"".to_s
      COL_POW = Proc.new{|n| n.pow(Aro::Mancy::S.to_f / Aro::Mancy::OS.to_f).to_i}
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show
        draw([
          "the #{self.name} room.",
          "",
          "getting directory listing...",
          "",
          Aos::Os.instance.get_ls([], true)
        ])
      end

      def self.draw(body_lines)
        return false unless body_lines.kind_of?(Array)
        lines = []
        dc = Aro::Config.display_configuration
        height = dc[:HEIGHT]
        width = dc[:WIDTH]

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
        Aos::S.say(lines.join("\n"))

        # explicitly return true
        true
      end

      def self.get_aos_display_lines
        # current Aos::Os output
        lines = []
        unless Aos::Os.instance.display_lines.empty?
          dc = Aro::Config.display_configuration
          width = dc[:WIDTH]
          lines << "".center(width)
          display_dim = get_display_dimension
          Aos::Os.instance.display_lines.each{|line|
            lines << line
          }
          lines << "".center(width)
          present_users = Aos::You.order(
            name: :asc
          ).where(
            pwd: Aos::Os.instance.you.pwd,
            access: [:agodo, :user]
          ).map{|y|
            (Aos::Os.instance.you == y ? Aos::Os::STAR.to_s : "") +
            y.name
          }

          if present_users.any?
            lines << "[ yous in the room ]".center(width)
            lines << ("[  " + present_users.join("    ") + "  ]").center(width)
          end
          lines << ":you_are_root".center(width) if Aos::Os.instance.you.root?
          lines << "v#{Aro::VERSION.to_s}".ljust(width - display_dim.length) + display_dim
        end

        lines
      end

      def self.get_display_dimension
        "#{Aro::T.read_dev_tarot(true).rjust(Aro::Mancy::V)} :<[#{self.get_dimension}]<"
      end

      def self.get_dimension
        (Aro::T.is_dev_tarot? ? Aro::T::DEV_TAROT : Aro::T::RUBY_FACOT)
      end

      def self.get_domain
        Aro::Dom.in_arodom? ? Aro::Dom::domain : Aro::Mancy.domain
      end

      def self.get_clock
        Time.now.strftime(Aos::Os::DATE_FORMAT)
      end

      def self.viewport_width
        dc = Aro::Config.display_configuration
        width = dc[:WIDTH]
        bar_width = (Aos::Vw::Base::BAR.length * Aro::Mancy::OS)
        h_margin_width = (Aos::Vw::Base::MARGIN_H * Aro::Mancy::OS)

        (width - (bar_width + h_margin_width))
      end

      def self.get_body_line(line)
        hm = Aos::Vw::Base::MARGIN_H
        bar = Aos::Vw::Base::BAR
        hm_space = " " * Aos::Vw::Base::MARGIN_H
        just = Aro::Config.display_configuration[:WIDTH] - (hm_space.length + bar.length)
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

      def self.debug_log(lines)
        Aro::V.say(lines)
      end
    end
  end
end
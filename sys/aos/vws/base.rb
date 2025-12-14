=begin
  
  vws/base.rb

  the base view (abstract).

  by i2097i

=end

require :aro.to_s

module Aos
  module Vw
    class Base
      BAR = :"".to_s
      COL_POW = Proc.new{|n| n.pow(Aro::Mancy::S.to_f / Aro::Mancy::OS.to_f).to_i}
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show
        draw([self.name])
      end

      def self.get_json(lines)
        {
          body: lines,
          you: Aos::Os.instance.you.to_json,
          domain: self.get_domain,
          clock: self.get_clock,
          dimension: self.get_dimension,
          dev_tarot: self.get_dt,
        }
      end

      def self.draw(body_lines)
        unless Aro::Config.is_format_text?
          Aos::S.say(self.get_json(lines))
          return true
        end

        return false unless body_lines.kind_of?(Array)
        lines = []
        dc = Aro::Config.display_configuration
        height = dc[:HEIGHT]
        width = dc[:WIDTH]

        # header
        # lines << "".center(width, "=")
        # lines << "".center(width)

        # half = ((width - self.name.length) / Aro::Mancy::OS.to_f).ceil
        # domain = self.get_domain
        # clock = self.get_clock
        # lines << (
        #   (
        #     domain.ljust(half) + self.name.to_s.upcase
        #   ).ljust(width - clock.length) + clock
        # )

        # lines << "".center(width, dc[:DIVIDER])

        # top vertical margin
        Aos::Vw::Base::MARGIN_V.times do
          lines << get_body_line("")
        end

        # yield => print lines
        body_lines.each{|line|
          lines << get_body_line(line)
        }

        lines += get_aos_display_lines

        # footer
        # display_dim = self.get_display_dimension
        # lines << (
        #   (
        #     ">[#{domain}]>#{Aos::Os::osify(Aos::Os.instance.you&.pwd || Dir.pwd)}"
        #   ).ljust(width - display_dim.length) + display_dim
        # )

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
          lines << "v#{Aro::VERSION.to_s}".ljust(width - display_dim.length) + display_dim
          # lines << "".center(width, "=")
        end
        lines
      end

      def self.get_display_dimension
        "#{self.get_dt.rjust(Aro::Mancy::V)} :<[#{self.get_dimension}]<"
      end

      def self.get_dt
        Aro::T.read_dev_tarot.strip[Aro::Mancy::S..]
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
        cmd_lines = []
        key_proc = Proc.new{|k| "$ #{k}"}
        desc_proc = Proc.new{|desc| "#{"desc:".rjust(just_cmds)} #{desc}"}
        usage_proc = Proc.new{|usage| "#{"usage:".rjust(just_cmds)} #{usage}"}

        cmd_lines << key_proc.call(cmd[:key])
        cmd_lines << desc_proc.call(cmd[:description])
        cmd_lines << usage_proc.call(cmd[:usage])
        (cmd[:cmds] || []).each{|k, v|
          cmd_lines << key_proc.call("#{cmd[:key]} #{v[:key]}")
          cmd_lines << desc_proc.call(v[:description])
          cmd_lines << usage_proc.call(v[:usage])
        }

        cmd_lines
      end

      def self.debug_log(lines)
        Aro::V.say(lines)
      end
    end
  end
end
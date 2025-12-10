=begin
  
  views/base.rb

  the base view (abstract).

  by i2097i

=end

require :aro.to_s

module Aos
  module Vi
    class Base
      BAR = :"".to_s
      COL_POW = Proc.new{|n| n.pow(Aro::Mancy::S.to_f / Aro::Mancy::OS.to_f).to_i}
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show(model)
        draw([self.name], model)
      end

      def self.get_json(lines, you = nil)
        {
          body: lines,
          you: you&.to_json,
          domain: self.get_domain,
          clock: self.get_clock,
          dimension: self.get_dimension,
          dev_tarot: self.get_dt,
        }
      end

      def self.draw(lines, you = nil)
        unless CLI::Config.is_format_text?
          Aos::S.say(self.get_json(lines, you))
          return true
        end

        return false unless lines.kind_of?(Array)

        dc = CLI::Config.display_config
        height = dc[:HEIGHT]
        width = dc[:WIDTH]

        print_aos_div

        # header
        Aro::Mancy::S.times do |i|
          Aos::S.say("".center(width, dc[:DIVIDER]))
          Aos::S.say("".center(width))
          Aos::S.say("\n")
        end

        half = ((width - self.name.length) / Aro::Mancy::OS.to_f).ceil
        domain = self.get_domain
        clock = self.get_clock
        Aos::S.say(
          (
            domain.ljust(half) + self.name.to_s.upcase
          ).ljust(width - clock.length) + clock
        )

        Aro::Mancy::S.times do
          Aos::S.say("".center(width, dc[:DIVIDER]))
        end

        # top vertical margin
        Aos::Vi::Base::MARGIN_V.times do
          Aos::S.say(get_body_line(""))
        end

        # yield => print lines
        lines.each{|line|
          Aos::S.say(get_body_line(line))
        }

        # bottom vertical margin
        Aos::Vi::Base::MARGIN_V.times do
          Aos::S.say("[#{Aos::Os} v#{Aro::VERSION.to_s}]".center(width))
        end

        # footer
        display_dim = self.get_display_dimension
        Aos::S.say(
          (
            ">[#{domain}]>#{Aos::Os::osify(you&.pwd || Dir.pwd)}"
          ).ljust(width - display_dim.length) + display_dim
        )

        print_aos_div
        # explicitly return true
        true
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

      def self.print_aos_div
        Aro::Mancy::S.times do
          Aos::S.say("\n")
          Aos::S.say("".center(CLI::Config.display_config[:WIDTH], "="))
        end
      end

      def self.viewport_width
        dc = CLI::Config.display_config
        width = dc[:WIDTH]
        bar_width = (Aos::Vi::Base::BAR.length * Aro::Mancy::OS)
        h_margin_width = (Aos::Vi::Base::MARGIN_H * Aro::Mancy::OS)

        (width - (bar_width + h_margin_width))
      end

      def self.get_body_line(line)
        hm = Aos::Vi::Base::MARGIN_H
        bar = Aos::Vi::Base::BAR
        hm_space = " " * Aos::Vi::Base::MARGIN_H
        just = CLI::Config.display_config[:WIDTH] - (hm_space.length + bar.length)
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
=begin
  
  views/base.rb

  the base view (abstract).

  by i2097i

=end

require :aro.to_s

module Aos
  module Vi
    class Base
      BAR = :"|".to_s
      MARGIN_V = Aro::Mancy::S
      MARGIN_H = Aro::Mancy::S

      def self.show(model)
        unless Aro::Mancy.game.nil?
          Aro::Mancy.game.show
          return
        end

        # default view
        draw([self.name], model)
      end

      def self.draw(lines, you = nil)
        return false unless lines.kind_of?(Array)

        dc = CLI::Config.display_config
        height = dc[:HEIGHT]
        width = dc[:WIDTH]

        # lines printed
        printed = Aro::Mancy::O

        # max printable lines
        # vertical margins
        max_lines = height - Aos::Vi::Base::MARGIN_V * Aro::Mancy::OS
        # footer
        max_lines = max_lines + Aro::Mancy::S

        # header
        Aro::Mancy::S.times do |i|
          printed += Aro::Mancy::OS
          Aos::S.say("".center(width, dc[:DIVIDER]))
          printed += Aro::Mancy::OS
          Aos::S.say("".center(width))
          Aos::S.say("\n")
        end

        half = ((width - self.name.length) / Aro::Mancy::OS.to_f).ceil
        domain = Aro::Dom.in_arodom? ? Aro::Dom::domain : Aro::Mancy.domain
        clock = Time.now.strftime(Aos::Os::DATE_FORMAT)
        printed += Aro::Mancy::S
        Aos::S.say(
          (
            domain.ljust(half) + self.name.to_s.upcase
          ).ljust(width - clock.length) + clock
        )

        Aro::Mancy::S.times do
          printed += Aro::Mancy::S
          Aos::S.say("".center(width, dc[:DIVIDER]))
        end

        # top vertical margin
        Aos::Vi::Base::MARGIN_V.times do
          printed += Aro::Mancy::S
          print_regular_line("")
        end

        # yield => print lines
        lines.each{|line|
          next if printed == max_lines

          printed += Aro::Mancy::S
          print_regular_line(line)
        }

        # fill empty space
        while printed < max_lines
          printed += Aro::Mancy::S
          print_regular_line("")
        end

        # bottom vertical margin
        Aos::Vi::Base::MARGIN_V.times do
          printed += Aro::Mancy::S
          Aos::S.say("[#{Aos::Os} v#{Aro::VERSION.to_s}]".center(width, :"-".to_s))
        end

        # footer
        dimension = (Aro::T.is_dev_tarot? ? Aro::T::DEV_TAROT : Aro::T::RUBY_FACOT)
        dt = Aro::T.read_dev_tarot.strip[Aro::Mancy::S..]
        display_dim = "#{dt.rjust(Aro::Mancy::V)} :<[#{dimension}]<"
        Aos::S.say(
          (
            ">#{domain}>#{Aos::Os::osify(you&.pwd || Dir.pwd)}"
          ).ljust(width - display_dim.length) + display_dim
        )
        Aos::S.say("".center(width, dc[:DIVIDER]))

        # debug logging
        Aro::D.say("invalid printed height: #{height}, printed: #{printed}") if printed != height

        # explicitly return true
        true
      end

      def self.viewport_width
        dc = CLI::Config.display_config
        width = dc[:WIDTH]
        bar_width = (Aos::Vi::Base::BAR.length * Aro::Mancy::OS)
        h_margin_width = (Aos::Vi::Base::MARGIN_H * Aro::Mancy::OS)

        (width - (bar_width + h_margin_width))
      end

      def self.print_regular_line(line)
        hm = Aos::Vi::Base::MARGIN_H
        bar = Aos::Vi::Base::BAR
        hm_space = " " * Aos::Vi::Base::MARGIN_H
        just = CLI::Config.display_config[:WIDTH] - (hm_space.length + bar.length)
        Aos::S.say((bar + hm_space + (line || "")).ljust(just) + hm_space + bar)
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
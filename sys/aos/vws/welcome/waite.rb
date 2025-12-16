=begin

  vws/welcome/waite.rb

  the welcome waite view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vw
    class Waite < Aos::Vw::Base
      def self.show
        # print all commands
        lines = []
        lines << ""
        lines << I18n.t("aos.constants.commands")
        lines << ""
        Aos::Os::CMDS.values.each{|v|
          lines += lines_for_cmd(v)
        }

        # draw output
        draw(lines)
      end
    end
  end
end
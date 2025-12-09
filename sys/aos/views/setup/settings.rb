=begin
  
  views/settings/settings.rb

  the settings view.

  by i2097i

=end

require_relative :"../base".to_s

module Aos
  module Vi
    class Settings < Aos::Vi::Base
      def self.show(model)
        just_access = Aro::Mancy::NUMERALS[:VI]
        just_key = Aro::Mancy::NUMERALS[:XXII]
        just_value = Aro::Mancy::NUMERALS[:VI]
        bullet = ":"

        # print CLI::Config::DEF
        lines = []
        lines << "<CLI::Config::DEF>"
        lines += CLI::Config.dump_config

        # print config commands
        lines << ""
        lines << I18n.t("aos.constants.commands")
        lines += lines_for_cmd(Aos::Os::CMDS[:CONFIG])

        # draw output
        draw(lines, model)
      end
    end
  end
end
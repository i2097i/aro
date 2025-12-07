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
        just_key = Aro::Mancy::NUMERALS[:XXI]
        just_value = Aro::Mancy::NUMERALS[:VI]
        bullet = ":"

        # print CLI::Config::DEF
        lines = []
        lines << "CLI::Config::DEF:"
        lines << "#{"access".rjust(just_access)}#{bullet} #{"variable_name".ljust(just_key)}=value"
        lines << ""
        CLI::Config::DEF.each{|k, deff|
          val = nil

          if deff[:access] == CLI::Config::DEF_ACCESS[:READ]
            val = CLI::Config.ovar(k)
          else
            val = CLI::Config.ivar(k)
            k = CLI::Config.ivar_k(k)
          end

          lines << "#{deff[:access].to_s.rjust(just_access)}#{bullet} #{k.to_s.ljust(just_key)}=#{val}"
        }

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
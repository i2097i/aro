=begin

  data.rb

  aos data management.

  by i2097i

=end

module Aos
  class Data
    include Singleton

    attr_accessor :display_lines

    CMDS = {
      ILOGS: {
        key: :ilogs,
        description: I18n.t("data.commands.description.ilogs"),
        usage: I18n.t("data.commands.usage.ilogs"),
      },
      YOUS: {
        key: :yous,
        description: I18n.t("data.commands.description.yous"),
        usage: I18n.t("data.commands.usage.yous"),
      },
    }

    def initialize
      self.display_lines = Aos::Data.base_lines
    end

    def self.process_cmd(args)
      self.instance.display_lines = []
      if args[Aro::Mancy::S].nil? ||
        CLI::FLAGS[:HELP].include?(args[Aro::Mancy::S].to_sym)
        Aos::Data.data
        return true
      end

      case args[Aro::Mancy::S].to_sym
      when Aos::Data::CMDS[:ILOGS][:key]
        Aos::Data.ilogs
        return true
      when Aos::Data::CMDS[:YOUS][:key]
        Aos::Data.yous
        return true
      end

      return false
    end

    def self.ilogs
      self.instance.display_lines = Aos::Data.ilog_lines
    end

    def self.yous
      self.instance.display_lines = Aos::Data.you_lines
    end

    def self.data
      self.instance.display_lines = Aos::Data.base_lines
    end

    def self.base_lines
      # print data commands
      lines = []
      lines << ""
      lines << I18n.t("aos.constants.commands")
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:DATA])
      lines << I18n.t("aos.constants.subcommands")
      Aos::Data::CMDS.keys.each{|k|
        lines += Aos::Vw::Base.lines_for_cmd(Aos::Data::CMDS[k])
      }
      lines << ""

      lines
    end

    def self.ilog_lines
      # list input ilogs
      lines = []
      lines << ""
      ilogs = Aos::Ilog.all
      unless ilogs.any?
        lines << I18n.t("data.messages.no_ilogs")
      else
        lines << I18n.t("data.messages.listing_ilogs")
        ilogs.each{|il|
          lines += il.get_lines
        }
      end
      lines << ""

      lines
    end

    def self.you_lines
      # list yous
      lines = []
      lines << ""
      yous = Aos::You.all
      unless yous.any?
        lines << I18n.t("data.messages.no_yous")
      else
        lines << I18n.t("data.messages.listing_yous")
        yous.each{|y|
          lines += y.get_lines
        }
      end
      lines << ""

      lines
    end
  end
end

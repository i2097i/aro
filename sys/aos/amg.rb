=begin

  amg.rb

  aos system management.

  by i2097i

=end

module Aos
  class Amg
    include Singleton

    attr_accessor :display_lines

    CMDS = {
      INST: {
        key: :inst,
        description: I18n.t("amg.commands.description.inst"),
        usage: I18n.t("amg.commands.usage.inst"),
      },
      INSTUN: {
        key: :instun,
        description: I18n.t("amg.commands.description.instun"),
        usage: I18n.t("amg.commands.usage.instun"),
      },
    }

    def initialize
      self.display_lines = Aos::Amg.base_lines
    end

    def self.process_cmd(args)
      self.instance.display_lines = []
      if args[Aro::Mancy::S].nil? ||
        CLI::FLAGS[:HELP].include?(args[Aro::Mancy::S].to_sym)
        Aos::Amg.amg
        return true
      end

      case args[Aro::Mancy::S].to_sym
      when Aos::Amg::CMDS[:INST][:key]
        unless args[Aro::Mancy::OS].nil?
          ilib_name = args[Aro::Mancy::OS]
          ilib = Aos::Ilib.find_by(name: ilib_name)
          unless ilib.nil?
            if ilib.installed?
              self.instance.display_lines << I18n.t("amg.messages.already_installed", name: ilib_name)
            else
              Aos::Amg.install(ilib)
              if ilib.reload.installed?
                self.instance.display_lines << I18n.t("amg.messages.install_success", name: ilib_name)
                self.instance.display_lines += self.inst_lines
                return true
              else
                self.instance.display_lines << I18n.t("amg.messages.install_failure", name: ilib_name)
              end
            end
          else
            self.instance.display_lines << I18n.t("amg.messages.cannot_locate", name: ilib_name)
          end
        else
          # list installed ilibs
          Aos::Amg.inst
          return true
        end
      when Aos::Amg::CMDS[:INSTUN][:key]
        unless args[Aro::Mancy::OS].nil?
          ilib_name = args[Aro::Mancy::OS]
          ilib = Aos::Ilib.find_by(name: ilib_name)
          unless ilib.nil?
            if ilib.available?
              self.instance.display_lines << I18n.t("amg.messages.not_installed", name: ilib_name)
            else
              Aos::Amg.uninstall(ilib)
              if ilib.reload.available?
                self.instance.display_lines << I18n.t("amg.messages.uninstall_success", name: ilib_name)
                self.instance.display_lines += self.instun_lines
                return true
              else
                self.instance.display_lines << I18n.t("amg.messages.uninstall_failure", name: ilib_name)
              end
            end
          else
            self.instance.display_lines << I18n.t("amg.messages.cannot_locate", name: ilib_name)
          end
        else
          # list available ilibs
          Aos::Amg.instun
          return true
        end
      end

      return false
    end

    def self.load(ilib_name)
      Aos::Ilib.find_or_create_by(name: ilib_name)
    end

    def self.install(ilib)
      return unless ilib.kind_of?(Aos::Ilib)
      ilib.installed!
    end

    def self.uninstall(ilib)
      return unless ilib.kind_of?(Aos::Ilib)
      ilib.available!
    end

    def self.inst
      self.instance.display_lines = Aos::Amg.inst_lines
    end

    def self.instun
      self.instance.display_lines = Aos::Amg.instun_lines
    end

    def self.amg
      self.instance.display_lines = Aos::Amg.base_lines
    end

    def self.base_lines
      # print amg commands
      lines = []
      lines << ""
      lines << I18n.t("aos.constants.commands")
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:AMG])
      lines << I18n.t("aos.constants.subcommands")
      Aos::Amg::CMDS.keys.each{|k|
        lines += Aos::Vw::Base.lines_for_cmd(Aos::Amg::CMDS[k])
      }
      lines << ""

      lines
    end

    def self.inst_lines
      # list installed ilibs
      lines = []
      lines << ""
      installed_ilibs = Aos::Ilib.where(status: :installed)
      unless installed_ilibs.any?
        lines << I18n.t("amg.messages.none_installed")
      else
        lines << I18n.t("amg.messages.listing_installed")
        lines += Aos::Amg.ilib_lines(installed_ilibs)
      end
      lines << ""

      lines
    end

    def self.instun_lines
      # list installed ilibs
      lines = []
      lines << ""
      available_ilibs = Aos::Ilib.where(status: :available)
      unless available_ilibs.any?
        lines << I18n.t("amg.messages.none_available")
      else
        lines << I18n.t("amg.messages.listing_available")
        lines += Aos::Amg.ilib_lines(available_ilibs)
      end
      lines << ""

      lines
    end

    def self.ilib_lines(ilibs)
      lines = []
      ilibs.each_with_index{|ilib, i|
        lines << "[#{i + Aro::Mancy::S} of #{ilibs.count}]"
        lines << I18n.t("amg.messages.ilib_name", name: ilib.name)
        lines << I18n.t("amg.messages.ilib_path", path: ilib.so_path.split("/").last(Aro::Mancy::N).join("/"))
        lines << I18n.t("amg.messages.ilib_usage", usage: ilib.usage)
      }

      lines
    end

  end
end

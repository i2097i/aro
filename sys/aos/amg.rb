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
        description: I18n.t("aos.amg.commands.description.inst"),
        usage: I18n.t("aos.amg.commands.usage.inst"),
      },
      INSTUN: {
        key: :instun,
        description: I18n.t("aos.amg.commands.description.instun"),
        usage: I18n.t("aos.amg.commands.usage.instun"),
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
          lib_name = args[Aro::Mancy::OS]
          lib = Aos::Lib.find_by(name: lib_name)
          unless lib.nil?
            if lib.installed?
              self.instance.display_lines << "#{lib_name} lib is already installed."
            else
              Aos::Amg.install(lib)
              if lib.reload.installed?
                self.instance.display_lines << "#{lib_name} installed successfully."
                self.instance.display_lines += self.inst_lines
                return true
              else
                self.instance.display_lines << "failed to install #{lib_name}."
              end
            end
          else
            self.instance.display_lines << "could not find #{lib_name} lib."
          end
        else
          # list installed libs
          Aos::Amg.inst
          return true
        end
      when Aos::Amg::CMDS[:INSTUN][:key]
        unless args[Aro::Mancy::OS].nil?
          lib_name = args[Aro::Mancy::OS]
          lib = Aos::Lib.find_by(name: lib_name)
          unless lib.nil?
            if lib.available?
              self.instance.display_lines << "#{lib_name} lib is not installed."
            else
              Aos::Amg.uninstall(lib)
              if lib.reload.available?
                self.instance.display_lines << "#{lib_name} uninstalled successfully."
                self.instance.display_lines += self.instun_lines
                return true
              else
                self.instance.display_lines << "failed to uninstall #{lib_name}."
              end
            end
          else
            self.instance.display_lines << "could not find #{lib_name} lib."
          end
        else
          # list available libs
          Aos::Amg.instun
          return true
        end
      end

      return false
    end

    def self.load(lib)
      Aos::Lib.find_or_create_by(name: lib)
    end

    def self.install(lib)
      return unless lib.kind_of?(Aos::Lib)
      lib.installed!
    end

    def self.uninstall(lib)
      return unless lib.kind_of?(Aos::Lib)
      lib.available!
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
      # list installed libs
      lines = []
      lines << ""
      installed_libs = Aos::Lib.where(status: :installed)
      unless installed_libs.any?
        lines << I18n.t("aos.amg.lib.none_installed")
      else
        lines << I18n.t("aos.amg.lib.listing_installed")
        installed_libs.each_with_index{|lib, i|
          lines << "[#{i + Aro::Mancy::S} of #{Aos::Lib.count}]"
          lines << "name: #{lib.name}"
          lines << "path: " + lib.so_path.split("/").last(Aro::Mancy::N).join("/")
          lines << "usage: #{lib.usage}"
        }
      end
      lines << ""

      lines
    end

    def self.instun_lines
      # list installed libs
      lines = []
      lines << ""
      available_libs = Aos::Lib.where(status: :available)
      unless available_libs.any?
        lines << I18n.t("aos.amg.lib.none_available")
      else
        lines << I18n.t("aos.amg.lib.listing_available")
        available_libs.each_with_index{|lib, i|
          lines << "[#{i + Aro::Mancy::S} of #{Aos::Lib.count}]"
          lines << "name: #{lib.name}"
          lines << "path: " + lib.so_path.split("/").last(Aro::Mancy::N).join("/")
          lines << "usage: #{lib.usage}"
        }
      end
      lines << ""

      lines
    end

  end
end

=begin

  flie.rb

  aos flie management.

  by i2097i

=end

module Aos
  class Flie
    include Singleton

    attr_accessor :display_lines, :pxy_running

    CMDS = {
      PXY: {
        key: :pxy,
        description: I18n.t("flie.commands.description.pxy"),
        usage: I18n.t("flie.commands.usage.pxy"),
      },
    }

    def initialize
      self.pxy_running = false
      self.display_lines = Aos::Flie.base_lines
    end

    # configure proxy for user.
    # $ flie pxy <email_address>
    # create a proxy for user.
    # $ flie pxy new <email_address>
    # update a proxy for user.
    # $ flie pxy update <email_address>
    # derez a proxy for user.
    # $ flie pxy derez <email_address>
    PXY_CMDS = {
      CREATE: :create,
      LIST: :list,
      DEREZ: :derez,
      HELP: :help,
      EXIT: :exit,
    }
    def self.pxy
      em = Aos::S.p.ask("#{Aos::Os::PS1}#{I18n.t("flie.messages.enter_email")}")
      if you = Aos::You.find_by(name: em)
        Aos::Os.instance.display_lines = []
        self.instance.pxy_running = true
        self.instance.display_lines = [I18n.t("flie.messages.pxy_starting")]
        while self.instance.pxy_running
          answer = Aro::P.p.select(
            Aos::Os::PS1.to_s + I18n.t("flie.messages.main_menu", name: you.name),
            Aos::Flie::PXY_CMDS,
            default: Aro::Mancy::S
          )

          case answer.to_sym
          when Aos::Flie::PXY_CMDS[:CREATE]
            cmd = Aos::S.p.ask("#{Aos::Os::PS1}#{I18n.t("flie.messages.enter_cmd")}")
            you.fpxies.create(cmd: cmd)
            self.instance.display_lines = you.fpxies.map{|f| f.display_lines}
          when Aos::Flie::PXY_CMDS[:LIST]
            if you.fpxies.any?
              self.instance.display_lines = you.fpxies.map{|f| f.display_lines}
            else
              self.instance.display_lines = [I18n.t("flie.messages.no_fpxies")]
            end
          when Aos::Flie::PXY_CMDS[:DEREZ]
            derez_answer = Aro::P.p.select(
              Aos::Os::PS1.to_s + I18n.t("flie.messages.derez_menu"),
              you.fpxies.map{|f| [f.cmd, f.id]}.to_h,
              default: Aro::Mancy::O
            )
          when Aos::Flie::PXY_CMDS[:HELP]
            Aos::Flie.flie
          when Aos::Flie::PXY_CMDS[:EXIT]
            self.instance.pxy_running = false
          end

          Aos::Os.instance.render
        end

        # exit display
        Aos::Flie.flie
        self.instance.display_lines += [I18n.t("flie.messages.pxy_exited")]
      else
        self.instance.display_lines += [I18n.t("flie.messages.invalid_email")]
      end

    end

    def self.flie
      self.instance.display_lines = Aos::Flie.base_lines
    end

    def self.process_cmd(args)
      self.instance.display_lines = []
      if args[Aro::Mancy::S].nil? ||
        CLI::FLAGS[:HELP].include?(args[Aro::Mancy::S].to_sym)
        Aos::Flie.flie
        return true
      end

      case args[Aro::Mancy::S].to_sym
      when Aos::Flie::CMDS[:PXY][:key]
        Aos::Flie.pxy
        return true
      end

      return false
    end

    def self.base_lines
      # print flie commands
      lines = []
      lines << ""
      lines << I18n.t("aos.constants.commands")
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:FLIE])
      lines << I18n.t("aos.constants.subcommands")
      Aos::Flie::CMDS.keys.each{|k|
        lines += Aos::Vw::Base.lines_for_cmd(Aos::Flie::CMDS[k])
      }
      lines << ""

      lines
    end
  end
end

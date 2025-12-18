=begin

  abot.rb

  abot.

  by i2097i

=end

module Aos
  class Abot
    include Singleton

    attr_accessor :display_lines

    CMDS = {
      AGODO: {
        key: :agodo,
        description: I18n.t("abot.commands.description.agodo"),
        usage: I18n.t("abot.commands.usage.agodo"),
      },
      DEREZ: {
        key: :derez,
        description: I18n.t("abot.commands.description.derez"),
        usage: I18n.t("abot.commands.usage.derez"),
      },
      RATE: {
        key: :rate,
        description: I18n.t("abot.commands.description.rate"),
        usage: I18n.t("abot.commands.usage.rate"),
      },
      STOP: {
        key: :stop,
        description: I18n.t("abot.commands.description.stop"),
        usage: I18n.t("abot.commands.usage.stop"),
      },
      START: {
        key: :start,
        description: I18n.t("abot.commands.description.start"),
        usage: I18n.t("abot.commands.usage.start"),
      },
    }

    def self.cron_pid_file
      return "" if Aro::Dom.dom_root.nil? || Aro::Dom.room_path(:abot).nil?
      File.join(Aro::Dom.dom_root, Aro::Dom.room_path(:abot), "abot.pid")
    end

    def self.cron
      return if File.exist?(Aos::Abot.cron_pid_file)

      abot_pid = fork {
        log = File.open(File.join(Aro::Dom.dom_root, Aro::Dom.room_path(:abot), "abot.log"), "w+")
        STDOUT.reopen(log)
        STDERR.reopen(log)
        STDOUT.sync = true
        loop do
          Aos::Agodo.where(power: :on).each{|a|
            a.godo
          }
          sleep(Aro::Mancy::S)
        end
      }
      Process.detach(abot_pid)
      File.open(Aos::Abot.cron_pid_file, "w+") do |f|
        f.write(abot_pid)
      end
    end

    def self.process_cmd(args)
      if args[Aro::Mancy::S].nil?
        Aos::Abot.abot
        return true
      elsif CLI::FLAGS[:HELP].include?(args[Aro::Mancy::S].to_sym)
        self.instance.display_lines = [I18n.t("abot.usage")]
        return true
      end

      processed = false
      # clear display
      self.instance.display_lines = []
      case args[Aro::Mancy::S].to_sym
      when Aos::Abot::CMDS[:AGODO][:key]
        Aos::Abot.agodo(args)
        processed = true
      when Aos::Abot::CMDS[:DEREZ][:key]
        Aos::Abot.derez(args[Aro::Mancy::OS])
        processed = true
      when Aos::Abot::CMDS[:RATE][:key]
        Aos::Abot.rate(args)
        processed = true
      when Aos::Abot::CMDS[:STOP][:key]
        Aos::Abot.stop(args[Aro::Mancy::OS])
        processed = true
      when Aos::Abot::CMDS[:START][:key]
        Aos::Abot.start(args[Aro::Mancy::OS])
        processed = true
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end

      return processed
    end

    def self.abot
      self.instance.display_lines = Aos::Abot.base_lines
    end

    # create and list agodos
    def self.agodo(args)
      if args[Aro::Mancy::OS].nil?
        # list agodos
        self.instance.display_lines = Aos::Abot.agodo_lines
        return
      end

      if !args[Aro::Mancy::OS].nil? &&
        !args[Aro::Mancy::E].nil? &&
        !args[Aro::Mancy::N].nil?
        # create mode
        # abot agodo <go> <do> <rate>
        arg_go = args[Aro::Mancy::OS]
        arg_do = args[Aro::Mancy::E]
        arg_rate = args[Aro::Mancy::N]

        agodo_record = Aos::Agodo.new
        agodo_record.go = arg_go
        agodo_record.do = arg_do
        agodo_record.rate = arg_rate
        if agodo_record.save
          self.instance.display_lines << "successfully created an agodo named #{agodo_record.you.name}."
          self.instance.display_lines += Aos::Abot.agodo_lines
        else
          self.instance.display_lines += agodo_record.errors.to_a.map(&:downcase)
        end
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end
    end

    # update agodo rate
    def self.rate(args)
      agodo_you = Aos::You.find_by(
        name: args[Aro::Mancy::OS]&.strip&.upcase
      )

      if !agodo_you.nil? &&
        Aro::Config::int_valid?(args[Aro::Mancy::E]&.to_i)
        agodo_record = agodo_you.agodo
        agodo_record.update(rate: args[Aro::Mancy::E].to_i)
        self.instance.display_lines << "#{agodo_record.you.name} rate updated."
        self.instance.display_lines += Aos::Abot.agodo_lines
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end
    end

    # destroy an agodo
    def self.derez(agodo_name)
      n = agodo_name&.strip&.upcase
      agodo_you = Aos::You.find_by(name: n)
      unless agodo_you.nil?
        self.instance.display_lines << "derezing #{agodo_you.name} agodo."
        agodo_record = agodo_you.agodo
        agodo_record&.destroy
        agodo_you.ilogs.destroy_all
        agodo_you.destroy
        requery = Aos::You.find_by(name: n)
        if requery.nil? && requery&.agodo.nil?
          self.instance.display_lines << "successfully destroyed #{n} agodo."
        else
          self.instance.display_lines << "unable to destroyed the #{n} agodo."
        end
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end
    end

    # power off an agodo
    def self.stop(agodo_name)
      agodo_you = Aos::You.find_by(
        name: agodo_name&.strip&.upcase
      )
      unless agodo_you.nil?
        agodo_record = agodo_you.agodo
        agodo_record.update(power: :off)
        self.instance.display_lines << "#{agodo_record.you.name} stopped."
        self.instance.display_lines += Aos::Abot.agodo_lines
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end
    end

    # power on an agodo
    def self.start(agodo_name)
      agodo_you = Aos::You.find_by(
        name: agodo_name&.strip&.upcase
      )
      unless agodo_you.nil?
        agodo_record = agodo_you.agodo
        agodo_record.update(power: :on)

        self.instance.display_lines << "#{agodo_record.you.name} started."
        self.instance.display_lines += Aos::Abot.agodo_lines
      else
        self.instance.display_lines = [I18n.t("abot.messages.invalid_agodo_cmd")]
      end
    end

    # abot help
    def self.base_lines
      # print abot commands
      lines = []
      lines << ""
      lines << I18n.t("aos.constants.commands")
      lines += Aos::Vw::Base.lines_for_cmd(Aos::Os::CMDS[:ABOT])
      lines << I18n.t("aos.constants.subcommands")
      Aos::Abot::CMDS.keys.each{|k|
        lines += Aos::Vw::Base.lines_for_cmd(Aos::Abot::CMDS[k])
      }
      lines << ""

      lines
    end

    # show agodos
    def self.agodo_lines(agodos = nil)
      # list input agodos
      lines = []
      lines << ""
      agodos ||= Aos::Agodo.all
      unless agodos.any?
        lines << I18n.t("abot.messages.no_agodos")
      else
        lines << I18n.t("abot.messages.listing_agodos")
        agodos.each{|a|
          lines += a.you.get_lines
          lines += a.get_lines
        }
      end
      lines << ""

      lines
    end
  end
end

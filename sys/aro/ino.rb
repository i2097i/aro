=begin

  ino.rb

  aro and ino.

  by i2097i

=end

module Aro
  def self.ino
    Aro::Ino.process_command(ARGV)
  end

  class Ino
    include Singleton

    attr_accessor :scroll, :display_lines

    CMDS = {
      CREATE: {
        key: :create,
        description: I18n.t("ino.commands.description.create"),
        usage: I18n.t("ino.commands.usage.create"),
      }
    }

    def self.run

    end

    def self.process_command(args)
      self.instance.display_lines = args
      args = Aos::Os.sanitize_you(args)

      if args[Aro::Mancy::O].nil? ||
        CLI::FLAGS[:HELP].include?(args[Aro::Mancy::O].to_sym)
        self.instance.display_lines = [I18n.t("usage.ino")]
        Aos::Vw::Ino.show
        return
      end

      case args[Aro::Mancy::O].to_sym
      when Aro::Ino::CMDS[:CREATE][:key]
        CLI::Nterface.exit_error_missing_args!(:var_aro_name) if args[Aro::Mancy::S].nil?
        Aro::Db.load
        self.instance.scroll = Aro::Scroll.find_by(name: args[Aro::Mancy::S].strip)
        if self.instance.scroll.nil?
          self.instance.scroll = Aro::Scroll.create(name: args[Aro::Mancy::S].strip)
          self.instance.scroll.players << Aro::Player.create(you_id: Aos::Os.instance.you.id)
          self.instance.display_lines = self.instance.scroll.display_lines
        else
          self.instance.display_lines = [I18n.t("ino.error.scroll_exists")]
        end
      else
        self.instance.display_lines = [I18n.t("ino.messages.invalid_cmd")]
      end

      Aos::Vw::Ino.show
    end

  end
end

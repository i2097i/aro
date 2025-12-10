=begin

  aos.rb

  aos.

  by i2097i

=end

require :aro.to_s

module Aos

  def self.run
    begin
      Aos::Os.instance.run
    rescue Interrupt => e
      Aos.run
    end
  end

  def self.process
    cmd = ARGV.join(" ")
    Aro::D.say("processing cmd #{cmd}...")
    Aos::Os::instance.process_cmd(cmd)
  end

  class Os
    include Singleton

    attr_accessor :you, :running, :view, :db

    A = :"@"
    STAR = :"*"
    PS1 = :">[#{Aos::Os}]>: "
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"

    CMDS = {
      CD: {
        key: :cd,
        description: I18n.t("aos.commands.description.cd"),
        usage: I18n.t("aos.commands.usage.cd"),
      },
      CONFIG: {
        key: :config,
        description: I18n.t("aos.commands.description.config"),
        usage: I18n.t("aos.commands.usage.config"),
        cmds: {
          SET: {
            key: :set,
            description: I18n.t("aos.commands.description.config_set", prefix: CLI::Config::ARO_CONFIG_PREFIX),
            usage: I18n.t("aos.commands.usage.config_set"),
          }
        }
      },
      EXIT: {
        key: :exit,
        description: I18n.t("aos.commands.description.exit"),
        usage: I18n.t("aos.commands.usage.exit"),
      },
      LS: {
        key: :ls,
        description: I18n.t("aos.commands.description.ls"),
        usage: I18n.t("aos.commands.usage.ls"),
      },
      LL: {
        key: :ll,
        description: I18n.t("aos.commands.description.ll"),
        usage: I18n.t("aos.commands.usage.ll"),
      },
      PWD: {
        key: :pwd,
        description: I18n.t("aos.commands.description.pwd"),
        usage: I18n.t("aos.commands.usage.pwd"),
      },
    }

    def initialize
      if Aro::Dom.in_arodom? && !Aro::Dom.is_initialized?
        Aro::Dom.new.generate
      end
      @db = Aos::Db.new
      load_you
    end

    def load_you
      @you = Aos::You.where(name: :you).first
      @you = Aos::You.create(name: :you, pwd: Dir.pwd) if @you.nil?
      Aro::D.say(@you.inspect)
    end

    def load_view
      view_name = Aos::Os.osify(@you.pwd).split("/").last || :dom.to_s
      view_cls = nil
      begin
        view_cls = (Aos::Vi.name + "::#{view_name.capitalize}").constantize
      rescue
        view_cls = Aos::Vi::Base
      end

      Dir.chdir(@you.pwd) do
        if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
          view_cls = Aos::Vi::Game
        end
      end

      Aro::D.say("loading view #{view_cls}")
      @view = view_cls
    end

    def self.osify(path)
      return path unless Aro::Dom.in_arodom?
      path_arr = path.split("/")
      Aro::Dom::dom_root.split("/").each{|rdp| path_arr.delete(rdp)}
      path_arr.join("/")
    end

    def self.is_aos_command?(arg)
      # determine if command is Aos::Os::CMDS
      # passthrough to system if command is not in Aos::Os::CMDS
      Aos::Os::CMDS.values.map{|v| v[:key]}.include?(arg.to_sym)
    end

    def render
      load_view
      return if @view.nil?
      Dir.chdir(@you.reload.pwd) do
        if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
          system(:aro.to_s)
        else
          @view.show(@you)
        end
      end
    end

    def process_cmd(cmd)
      Dir.chdir(@you.reload.pwd) do
        passthrough = main(cmd)
        if CLI::Config.is_format_text?
          IO.console.goto(Aro::Mancy::O, Aro::Mancy::O)
        end
        if passthrough
          system(cmd)
          Aos::S.say("\n")
        else
          render
        end
      end

      CLI::EXIT_CODES[:SUCCESS]
    end

    def confgiure_readline
      # configure Readline
      # Readline.completion_append_character = "/"
      Readline.completion_proc = Proc.new{|str|
        # todo: the reserved_words search is working but the || case is not
        Aro::Dom::D.reserved_words.grep(/^#{Regexp.escape(str)}/) ||
        Dir[@you.pwd + str + Aos::Os::STAR.to_s].grep(/^#{Regexp.escape(str)}/)
      }
    end

    def run
      # run condition
      @running = true

      original_stdout = $stdout
      $stdout = StringIO.open do |out|
        cmd = nil
        loop do
          # erase before cursor
          IO.console.erase_screen(Aro::Mancy::S)
          process_cmd(cmd)
          IO.console.goto(CLI::Config.display_config[:HEIGHT], Aro::Mancy::O)
          break unless @running && cmd = Readline.readline(calc_ps1, true)
        end

        out
      end

      CLI::EXIT_CODES[:SUCCESS]
    ensure
      $stdout = original_stdout
    end

    def main(cmd)
      # begin game loop
      return false if cmd.nil?

      # get args
      args = cmd.split(" ")
      return false if args[0].nil?
      return false if args[0] == :aos.to_s

      # reconfigure for updates to pwd
      # todo: not working for tab completion
      confgiure_readline

      args = handle_aro_override(args)

      passthrough = !Aos::Os.is_aos_command?(args[Aro::Mancy::O]) ||
        args.include?(:aos.to_s)

      return false if handle_room_path(args[Aro::Mancy::O])

      # set aos pwd
      unless passthrough
        Dir.chdir(@you.pwd) do
          # process commands
          case args[Aro::Mancy::O].to_sym
          when Aos::Os::CMDS[:CONFIG][:key]
            # config
            passthrough = handle_config(args)
          when Aos::Os::CMDS[:LS][:key]
            # ls
            handle_ls(args)
          when Aos::Os::CMDS[:LL][:key]
            # ll
            handle_ll(args)
          when Aos::Os::CMDS[:PWD][:key]
            # pwd
            handle_pwd(args)
          when Aos::Os::CMDS[:EXIT][:key]
            # exit
            passthrough = true
            handle_exit(args)
          when Aos::Os::CMDS[:CD][:key]
            # cd
            handle_cd(args)
          end
        end
      end

      return passthrough
    end

    def calc_ps1
      you_pwd = Aos::Os::osify(@you.pwd)
      "#{Aos::Os::PS1}" # #{you_pwd.empty? ? "" : "#{you_pwd}:"}$ "
    end

    def handle_room_path(arg)
      # search for reserved room path
      handled = false
      room_path = Aro::Dom.room_path(arg)
      if !room_path.empty?
        handled = true
        @you.update(pwd: File.join(
          File.dirname(Aro::Dom.ethergeist_path),
          room_path
        ))
      end
      handled
    end

    def handle_aro_override(args)
      if args[0].include?(:aro.to_s)
        args = "#{args.join(" ")} #{:aos.to_s}".split(" ")
      end
      args
    end

    def handle_config(args)
      passthrough = false
      if args[1].nil?
        # show settings
        passthrough = true
        CLI::Config.dump_config.each{|l| Aos::S.say(l)}
      else
        CLI::Config.process_config_command(args)
      end
      passthrough
    end

    def handle_ls(args)
      Aos::S.say(Dir.glob(File.join(@you.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_EXTGLOB).map{|p| "/" + Aos::Os::osify(p)}.join("\n"))
    end

    def handle_ll(args)
      Aos::S.say(Dir.glob(File.join(@you.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_DOTMATCH).map{|p| "/" + Aos::Os::osify(p)}.join("\n"))
    end

    def handle_pwd(args)
      osified = "/" + Aos::Os::osify(@you.pwd)
      Aos::S.say(osified)
    end

    def handle_exit(args)
      Aos::S.say("#{Aos::Os} is exiting...")
      @running = false
    end

    def handle_cd(args)
      if args[1].nil? || args[1] == "~/"
        # no arg takes you to arodom root
        @you.update(pwd: File.dirname(Aro::Dom.ethergeist_path))
      else
        if args[1].include?(Aro::Dom::DOTT.to_s)
          # going up
          if File.dirname(Aro::Dom.ethergeist_path) == @you.pwd
            Aos::S.say("within #{Aos::Os}, one cannot leave the #{Aro::Dom}.")
          else
            # todo: support dots in paths
            # this only supports moving one level up

            pwd_arr = @you.pwd.split("/")
            new_pwd = (pwd_arr.first(pwd_arr.length - 1)).join("/")

            @you.update(pwd: new_pwd)
          end
        else
          # this particular block needs to be better
          if args[1][0] == "/"
            Aro::V.say("handling cd to root (/) arg...")
            Aro::V.say(Aro::Dom::dom_root)
            Aro::V.say(args[1][1..])
            args[1] = args[1][1..]
            new_pwd = File.join(Aro::Dom.dom_root, args[1])
            if Dir.exist?(new_pwd)
              @you.update(pwd: new_pwd)
            end
          elsif Dir.exist?(args[1]) && args[1] != Aro::Dom::DOT.to_s
            new_pwd = File.join(@you.pwd, args[1])
            Aro::V.say("new_pwd: #{new_pwd}")
            @you.update(pwd: new_pwd)
          else
            Aos::S.say("that directory is invalid.")
          end
        end
      end
    end
  end
end

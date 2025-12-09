=begin

  aos.rb

  aos.

  by i2097i

=end

require :aro.to_s

module Aos

  def self.run
    Aos::Db.new
    Aos::Os::boot(Aos::you)
    begin
      Aos::Os.instance.run
    rescue Interrupt => e
      Aos::run
    end
  end

  def self.watch
    Aos::Db.new
    Aos::Os::boot(Aos::you)
    Aos::Os::instance.render
  end

  def self.you
    you = Aos::You.where(name: :you).first
    you = Aos::You.create(name: :you, pwd: Dir.pwd) if you.nil?
    you
  end

  class Os
    include Singleton

    attr_accessor :you, :running, :view

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

    def self.boot(you)
      self.instance.you = you
      self.instance.load_view
    end

    def render
      return if view.nil?
      Dir.chdir(you.pwd) do
        view.show(you)
      end
    end

    def run
      # run loop exit condition
      self.running = true

      # set aos pwd
      Dir.chdir(you.pwd)

      # configure Readline
      # Readline.completion_append_character = "/"
      Readline.completion_proc = Proc.new{|str|
        # todo: the reserved_words search is working but the || case is not
        Aro::Dom::D.reserved_words.grep(/^#{Regexp.escape(str)}/) ||
        Dir[Dir.pwd + str + Aos::Os::STAR.to_s].grep(/^#{Regexp.escape(str)}/)
      }

      # begin game loop
      while running && cmd = Readline.readline(calc_ps1, true)
        next if cmd.nil?

        # get args
        args = cmd.split(" ")

        next if handle_room_path(args[Aro::Mancy::O]) || handle_aro_override(args)

        passthrough = !is_aos_command?(args[Aro::Mancy::O])

        # process commands
        case args[Aro::Mancy::O].to_sym
        when Aos::Os::CMDS[:CONFIG][:key]
          # config
          handle_config(args)
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
          handle_exit(args)
        when Aos::Os::CMDS[:CD][:key]
          # cd
          handle_cd(args)
        end

        Aos::S.say(system(cmd)) if passthrough
      end

      CLI::EXIT_CODES[:SUCCESS]
    end

    def load_view
      view_name = Aos::Os.osify(you.pwd).split("/").last || :dom.to_s
      view_cls = nil
      begin
        view_cls = (Aos::Vi.name + "::#{view_name.capitalize}").constantize
      rescue
        view_cls = Aos::Vi::Base
      end

      Aro::D.say("loading view #{view_cls}")
      self.view = view_cls
    end

    def calc_ps1
      you_pwd = Aos::Os::osify(you.pwd)
      "#{Aos::Os::PS1}#{you_pwd.empty? ? "" : "#{you_pwd}:"}$ "
    end

    def self.osify(path)
      return path unless Aro::Dom.in_arodom?
      path_arr = path.split("/")
      Aro::Dom::dom_root.split("/").each{|rdp| path_arr.delete(rdp)}
      path_arr.join("/")
    end

    def is_aos_command?(arg)
      # determine if command is Aos::Os::CMDS
      # passthrough to system if command is not in Aos::Os::CMDS
      Aos::Os::CMDS.values.map{|v| v[:key]}.include?(arg.to_sym)
    end

    def handle_room_path(arg)
      # search for reserved room path
      handled = false
      room_path = Aro::Dom.room_path(arg)
      if !room_path.empty?
        handled = true
        you.update(pwd: File.join(
          File.dirname(Aro::Dom.ethergeist_path),
          room_path
        ))
      end
      handled
    end

    def handle_aro_override(args)
      # run all aro commands in aos context
      handled = false
      if args[0].include?(:aro.to_s)
        # passthrough aro cmd with aos appended
        handled = true
        system("#{args.join(" ")} #{:aos.to_s}")
      end
      handled
    end

    def handle_config(args)
      if args[1].nil?
        # show settings
        you.update(pwd:
          File.join(
            File.dirname(Aro::Dom.ethergeist_path),
            Aro::Dom::SETUP.to_s,
            Aro::Dom::SETTINGS.to_s
          )
        )
      else
        CLI::Config.process_config_command(args)
      end
    end

    def handle_ls(args)
      Aos::S.say(Dir[File.join(Dir.pwd, (args[1] || "") + Aos::Os::STAR.to_s)].map{|p| "/" + Aos::Os::osify(p)}.join("\n"))
    end

    def handle_ll(args)
      Aos::S.say(Dir.glob(File.join(Dir.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_DOTMATCH).map{|p| "/" + Aos::Os::osify(p)}.join("\n"))
    end

    def handle_pwd(args)
      osified = "/" + Aos::Os::osify(you.pwd)
      Aos::S.say(osified)
    end

    def handle_exit(args)
      Aos::S.say("#{Aos::Os} is exiting...")
      self.running = false
    end

    def handle_cd(args)
      if args[1].nil? || args[1] == "~/"
        # no arg takes you to arodom root
        you.update(pwd: File.dirname(Aro::Dom.ethergeist_path))
      else
        if args[1].include?(Aro::Dom::DOTT.to_s)
          # going up
          if File.dirname(Aro::Dom.ethergeist_path) == you.pwd
            Aos::S.say("within #{Aos::Os}, one cannot leave the #{Aro::Dom}.")
          else
            # todo: support dots in paths
            # this only supports moving one level up

            pwd_arr = you.pwd.split("/")
            new_pwd = (pwd_arr.first(pwd_arr.length - 1)).join("/")

            you.update(pwd: new_pwd)
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
              you.update(pwd: new_pwd)
            end
          elsif Dir.exist?(args[1]) && args[1] != Aro::Dom::DOT.to_s
            new_pwd = File.join(you.pwd, args[1])
            Aro::V.say("new_pwd: #{new_pwd}")
            you.update(pwd: new_pwd)
          else
            Aos::S.say("that directory is invalid.")
          end
        end
      end
    end
  end
end

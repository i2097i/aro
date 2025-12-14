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

    attr_accessor :you, :libs, :running, :view, :db, :display_lines

    A = :"@"
    STAR = :"*"
    YOU = :you.to_s
    YOU_FLAG = :"--you".to_s
    PS1 = :">[#{Aos::Os}]>: "
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"

    CMDS = {
      AMG: {
        key: :amg,
        description: I18n.t("aos.commands.description.amg"),
        usage: I18n.t("aos.commands.usage.amg"),
      },
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
            description: I18n.t("aos.commands.description.config_set", prefix: Aro::Config::ARO_CONFIG_PREFIX),
            usage: I18n.t("aos.commands.usage.config_set"),
          }
        }
      },
      EXIT: {
        key: :exit,
        description: I18n.t("aos.commands.description.exit"),
        usage: I18n.t("aos.commands.usage.exit"),
      },
      HELP: {
        key: :help,
        description: I18n.t("aos.commands.description.help"),
        usage: I18n.t("aos.commands.usage.help"),
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

    def self.osify(path, leading_slash = false)
      return path unless Aro::Dom.in_arodom?
      path_arr = path.split("/")
      Aro::Dom::dom_root.split("/").each{|rdp| path_arr.delete(rdp)}
      result = path_arr.join("/")
      if leading_slash
        result = "/" + result
      end

      result
    end

    def self.is_aos_command?(arg)
      # determine if command is Aos::Os::CMDS
      # passthrough to system if command is not in Aos::Os::CMDS
      Aos::Os::CMDS.values.map{|v| v[:key]}.include?(arg.to_sym)
    end

    def self.you_flagd?
      self.instance.you&.name != Aos::Os::YOU
    end

    def self.sanitize_you(cmd)
      if cmd.present? && cmd.include?(Aos::Os::YOU_FLAG)
        cmd_split = cmd.split(" ")
        i = cmd_split.index(Aos::Os::YOU_FLAG)
        cmd_split.delete_at(i)
        cmd_split.delete_at(i)
        cmd = cmd_split.join(" ")
      end

      cmd
    end

    def initialize
      Aro::Config.instance.load
      if Aro::Dom.in_arodom? && !Aro::Dom.is_initialized?
        Aro::Dom.new.generate
      end
      @db = Aos::Db.new
      load_libs
      load_you
    end

    def load_libs
      # todo: load from directory of libs.
      # something like:
      #
      # Dir[lib_something_something].each do{|l| Aos::Lib.install(l)}

      # for now static
      Aos::Amg.load(:crs)
    end

    def load_you
      return if @you.present?

      you_name = Aos::Os::YOU
      if ARGV.include?(Aos::Os::YOU_FLAG)
        you_name = ARGV[ARGV.index(Aos::Os::YOU_FLAG) + Aro::Mancy::S]
      end

      @you = Aos::You.find_by(name: you_name)
      @you = Aos::You.create(name: you_name, pwd: Dir.pwd) if @you.nil?

      self.display_lines = [Aos::Os.osify(@you.pwd, true)]
    end

    def load_view
      view_name = Aos::Os.osify(@you.pwd).split("/").last || :dom.to_s
      view_cls = nil
      begin
        view_cls = (Aos::Vw.name + "::#{view_name.capitalize}").constantize
      rescue
        view_cls = Aos::Vw::Base
      end

      Dir.chdir(@you.pwd) do
        if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
          view_cls = Aos::Vw::Game
        end
      end

      Aro::D.say("loading view #{view_cls}")
      @view = view_cls
    end

    def render
      load_view
      return if @view.nil?
      Dir.chdir(@you.reload.pwd) do
        if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
          system(:aro.to_s)
        else
          @view.show
        end
      end
    end

    def process_cmd(cmd)
      Dir.chdir(@you.reload.pwd) do
        configure_readline
        passthrough = main(cmd)
        if Aro::Config.is_format_text?
          # IO.console.goto(Aro::Mancy::O, Aro::Mancy::O)
        end
        nothing = nil
        if passthrough
          nothing = system(cmd)
          Aos::S.say(nothing) if nothing.nil?
        end

        if nothing.nil?
          render
        end
      end

      CLI::EXIT_CODES[:SUCCESS]
    end

    def configure_readline
      # configure Readline
      Readline.completion_append_character = "/"
      Readline.completion_proc = Proc.new{|str|
        # Aro::V.say(str)
        dir_matcher = @you.pwd + "/" + str + Aos::Os::STAR.to_s
        dir_listing = Dir.glob(dir_matcher, File::FNM_DOTMATCH).map{|d| Aos::Os.osify(d)}
        r_str = Regexp.escape(str)

        # Aro::V.say(dir_listing.join(" ")) if dir_listing.any?
        # checks pwd
        matches = dir_listing.grep(/^#{r_str}/)
        if matches.any?
          matches
        else
          # checks reserved words
          Aro::Dom::D.reserved_words.grep(/^#{r_str}/)
        end
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
          process_cmd(cmd)
          IO.console.goto(Aro::Config.display_configuration[:HEIGHT], Aro::Mancy::O)
          break unless @running && cmd = Readline.readline(calc_ps1, true)
          IO.console.erase_screen(Aro::Mancy::S)
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
      args = Aos::Os.sanitize_you(cmd).split(" ")
      return false if args[0].nil?
      return false if args[0] == :aos.to_s

      args = handle_aro_override(args)

      passthrough = !Aos::Os.is_aos_command?(args[Aro::Mancy::O]) ||
        args.include?(:aos.to_s)

      # set aos pwd
      unless passthrough
        Dir.chdir(@you.pwd) do
          # process commands
          case args[Aro::Mancy::O].to_sym
          when Aos::Os::CMDS[:AMG][:key]
            # inst
            passthrough = handle_amg(args)
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
          when Aos::Os::CMDS[:HELP][:key]
            # help
            passthrough = handle_help(args)
          when Aos::Os::CMDS[:CD][:key]
            # cd
            handle_cd(args)
          end
        end
      end

      # if system is going to run
      # but redirect happens
      # cancel system run
      if passthrough && redirect_to_room(args[Aro::Mancy::O])
        return false
      end

      return passthrough
    end

    def calc_ps1
      you_pwd = Aos::Os::osify(@you.pwd)
      "#{Aos::Os::PS1}"
    end

    def handle_aro_override(args)
      if args[0].include?(:aro.to_s)
        args = "#{args.join(" ")} #{:aos.to_s}".split(" ")
      end
      args
    end

    def handle_config(args)
      Aro::Config.process_config_command(args)
      return true
    end

    def redirect_to_room(arg)
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

    def handle_amg(args)
      Aos::Amg.process_cmd(args)
    end

    def handle_help(args)
      redirect_to_room(Aro::Dom::WAITE)
      return false
    end

    def handle_ls(args)
      self.display_lines = [
        Dir.glob(File.join(@you.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_EXTGLOB).map{|p| "/" + Aos::Os::osify(p)}.join("\n")
      ]
    end

    def handle_ll(args)
      self.display_lines = [
        Dir.glob(File.join(@you.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_DOTMATCH).map{|p| Aos::Os::osify(p.strip, true)}.join("\n")
      ]
    end

    def handle_pwd(args)
      osified = "/" + Aos::Os::osify(@you.pwd)
      self.display_lines = [osified]
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
            self.display_lines = ["within #{Aos::Os}, one cannot leave the #{Aro::Dom}."]
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
            self.display_lines = ["that directory is invalid."]
          end
        end
      end
    end
  end
end

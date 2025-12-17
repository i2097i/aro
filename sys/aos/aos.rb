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

    attr_accessor :display_lines,
      :running,
      :view,
      :you,
      :you_flag

    A = :"@"
    STAR = :"*"
    YOU = :you.to_s
    YOU_FLAG = :"--you".to_s
    PS1 = :">[#{Aos::Os}]>: "
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"

    CMDS = {
      ABOT: {
        key: :abot,
        description: I18n.t("aos.commands.description.abot"),
        usage: I18n.t("aos.commands.usage.abot"),
      },
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
      },
      DATA: {
        key: :data,
        description: I18n.t("aos.commands.description.data"),
        usage: I18n.t("aos.commands.usage.data"),
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
      Aos::Os::CMDS.values.map{|v| v[:key]}.include?(arg.to_sym)
    end

    def self.you_flagd?
      self.instance.you_flag
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

    def self.cron
      Aos::Abot.cron
      # ...
    end

    def initialize
      self.you_flag = false
      Aro::Config.instance.load
      # if Aro::Dom.in_arodom? && !Aro::Dom.is_initialized?
        # Aro::Dom.new.generate unless Aro::Mancy.in_aro?
      # end
      Aos::Db.load
      load_ilibs
      load_you
      Aos::Abot.abot
    end

    def load_ilibs
      # todo: load from directory of ilibs.
      # something like:
      #
      # Dir[lib_something_something].each do{|l| Aos::Ilib.install(l)}

      # for now static
      Aos::Amg.load(:crs)
    end

    def load_you
      return if @you.present?

      if ARGV.include?(Aos::Os::YOU_FLAG)
        self.you_flag = true
        you_name = ARGV[ARGV.index(Aos::Os::YOU_FLAG) + Aro::Mancy::S]
        @you = Aos::You.find_by(name: you_name)
        if @you.nil?
          @you = Aos::You.create(name: you_name)
        end
      else
        # todo: make more secure
        @you = Aos::You.find_by(access: :root)
      end

      self.display_lines = [Aos::Os.osify(@you.pwd, true)]
    end

    def load_view
      view_name = Aos::Os.osify(@you.pwd).split("/").last || :dom.to_s
      view_cls = nil

      cls_name = (Aos::Vw.name + "::#{view_name.capitalize}")
      Aro::D.say("attempting to load view class #{cls_name}")
      begin
        view_cls = cls_name.constantize
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
        send_to_system_call = main(cmd)
        if Aro::Config.is_format_text?
          # IO.console.goto(Aro::Mancy::O, Aro::Mancy::O)
        end
        nothing = nil
        if send_to_system_call
          nothing = system(cmd)
          Aos::S.say(nothing) if nothing.nil?
        end

        if nothing.nil?
          render
        end

        unless cmd.nil?
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

      # start cron
      Aos::Os.cron

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

      # send to "system" call in process_cmd method
      # if args[Aro::Mancy::O] is not in Aos::Os::CMDS
      send_to_system_call = !Aos::Os.is_aos_command?(args[Aro::Mancy::O]) ||
        args.include?(:aos.to_s)

      # the command is valid
      unless send_to_system_call

        Dir.chdir(@you.pwd) do
          # process commands
          case args[Aro::Mancy::O].to_sym
          when Aos::Os::CMDS[:ABOT][:key]
            # abot
            send_to_system_call = Aos::Abot.process_cmd(args)
          when Aos::Os::CMDS[:AMG][:key]
            # amg
            send_to_system_call = Aos::Amg.process_cmd(args)
          when Aos::Os::CMDS[:CD][:key]
            # cd
            handle_cd(args)
          when Aos::Os::CMDS[:CONFIG][:key]
            # config
            send_to_system_call = true
            Aro::Config.process_command(args)
          when Aos::Os::CMDS[:DATA][:key]
            # data
            send_to_system_call = Aos::Data.process_cmd(args)
          when Aos::Os::CMDS[:EXIT][:key]
            # exit
            send_to_system_call = true
            handle_exit(args)
          when Aos::Os::CMDS[:HELP][:key]
            # help
            send_to_system_call = handle_help(args)
          when Aos::Os::CMDS[:LL][:key]
            # ll
            handle_ll(args)
          when Aos::Os::CMDS[:LS][:key]
            # ls
            handle_ls(args)
          when Aos::Os::CMDS[:PWD][:key]
            # pwd
            handle_pwd(args)
          end
        end
      end

      if send_to_system_call
        # process ilib commands
        ilib = Aos::Ilib.find_by(
          name: args[Aro::Mancy::O],
          status: :installed
        )
        unless ilib.nil?
          self.display_lines = [ilib.usage]
          send_to_system_call = false
        end

        # if system is going to run, but redirect happens,
        # cancel system run.
        if redirect_to_room(args[Aro::Mancy::O])
          send_to_system_call = false
        end
      end

      return send_to_system_call
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

    def handle_help(args)
      redirect_to_room(Aro::Dom::WAITE)
      return false
    end

    def handle_ls(args)
      self.display_lines = [get_ls(args)]
    end

    def get_ls(args, split = false)
      Dir.glob(
        File.join(
          @you.pwd,
          (args[1] || "") + Aos::Os::STAR.to_s
        ),
        File::FNM_EXTGLOB
      ).map{|p|
        "#{split ? "\n/" :"/"}" + Aos::Os::osify(p)
      }.join("\n")
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
      if File.exist?(Aos::Abot.cron_pid_file)
        system("kill -9 #{File.read(Aos::Abot.cron_pid_file)}")
        FileUtils.rm(Aos::Abot.cron_pid_file)
      end
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

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

  def self.fpx
    require_relative :"../fpx".to_s
    if ARGV[Aro::Mancy::S].nil?
      Aos::Fpx::Server.start
      return
    end

    case ARGV[Aro::Mancy::S].to_sym
    when :restart
      Aos::Fpx::Server.stop
      sleep(Aro::Mancy::S)
      Aos::Fpx::Server.start
    when :stop
      Aos::Fpx::Server.stop
    end
  end

  class Os
    include Singleton

    attr_accessor :display_lines,
      :q,
      :running,
      :stream_pid,
      :view,
      :you,
      :you_flag

    A = :"@"
    STAR = :"*"
    YOU = :you.to_s
    YOU_FLAG = :"--you".to_s
    DB_POOL = Aro::Mancy::NUMERALS[:XLII]
    PS1 = :">[#{Aos::Os}]>: "
    Q_PID = :"q.pid"
    Q_UP = :"q.up"
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
      COR: {
        key: :cor,
        description: I18n.t("aos.commands.description.cor"),
        usage: I18n.t("aos.commands.usage.cor"),
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
      FLIE: {
        key: :flie,
        description: I18n.t("aos.commands.description.flie"),
        usage: I18n.t("aos.commands.usage.flie"),
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
      Aro::Dom::dom_root.split("/").each{|rdp|
        path_arr.delete_at(path_arr.index(rdp)) unless path_arr.index(rdp).nil?
      }
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

    def self.sanitize_you(args = [])
      if args.any? && args.include?(Aos::Os::YOU_FLAG)
        i = args.index(Aos::Os::YOU_FLAG)
        args.delete_at(i)
        args.delete_at(i)
      end

      args
    end

    def self.cron
      Aos::Abot.cron
      # ...
    end

    def initialize
      Aos::Db.load
      load_ilibs
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

    def self.you_name_from_flag_arg
      yfi = ARGV.index(Aos::Os::YOU_FLAG)
      return ARGV[yfi + Aro::Mancy::S]&.strip unless yfi.nil?
    end

    Mutex.new.synchronize do
      def load_you!
        self.you_flag = nil
        self.you = Aos::You.find_by(access: :root)
        if ARGV.include?(Aos::Os::YOU_FLAG)
          you_name = Aos::Os.you_name_from_flag_arg
          unless you_name == self.you.name
            self.you = Aos::You.find_by(name: you_name)
            if self.you.nil?
              self.you = Aos::You.create(name: you_name)
              self.you.reload
            end
            self.you_flag = self.you
          end
        end

        Aro::V.say("you loaded:\n#{caller[Aro::Mancy::O..Aro::Mancy::N].join("\n")}")
        Aro::V.say(self.you.name)
        Aro::V.say(Aos::Os.osify(self.you.pwd))
      end
    end

    def load_you
      return unless self.you_flag.nil?
      load_you!
    end

    def get_pwd_for(you_name)
      Aos::You.find_by(name: you_name)&.pwd
    end

    def load_view
      view_name = Aos::Os.osify(self.you.pwd).split("/").last || :dom.to_s
      view_cls = nil

      if self.you.home?
        view_cls = Aos::Vw::Home
      else
        cls_name = (Aos::Vw.name + "::#{view_name.capitalize}")
        Aro::D.say("attempting to load view class #{cls_name}")
        begin
          view_cls = cls_name.constantize
        rescue
          view_cls = Aos::Vw::Base
        end

        Dir.chdir(self.you.pwd) do
          if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
            view_cls = Aos::Vw::Teck
          end
        end
      end

      Aro::D.say("loading view #{view_cls}")
      @view = view_cls
    end

    Mutex.new.synchronize do
      def render
        load_view
        return if @view.nil?

        Dir.chdir(self.you.reload.pwd) do
          if Aro::Mancy.in_aro?
            Aro::Mancy.init
            if Aro::Mancy.is_initialized? && !Aro::Mancy.teck.nil?
              Aro::Mancy.teck.show
            end
          else
            @view.show
          end
        end
      end
    end

    def self.q
      self.instance.q
    end

    Mutex.new.synchronize do
      def self.say(lines)
        unless Aro::Dom.is_initialized?
          Aos::S.say(lines.join("\n"))
          return
        end
        Aos::Db.load
        current_you = self.instance.you_flag || self.instance.you
        lines = [lines] unless lines.kind_of?(Array)
        if current_you.nil?
          Aos::S.say(lines.join("\n"))
        else
          # Mutex.new.synchronize do
            Aos::Os.instance.q ||= {}
            Aos::Os.q[current_you.name] ||= []
            Aos::Os.q[current_you.name] += lines
            # Aos::S.say("adding lines to #{current_you.name} (#{lines.count})")
            # Aos::S.say("total: #{Aos::Os.q[current_you.name].count})")
            # Aos::Os.streamq unless File.exist?(Aos::Os.q_pid_file)
            Aos::Os.q.keys.each{|you_name|
              current_you = Aos::You.find_by(
                name: you_name
              )
              # Aos::S.say("streaming #{Aos::Os.q[you_name].count} lines to #{current_you.name}")
              current_you.stream(
                Aos::Os.q.delete(you_name)
              )
            }
          # end
        end
      end
    end

    # def self.streamq
    #   return unless !Aos::Cor.is_test? && self.instance.stream_pid.nil?
    #   puts self.instance.q.inspect
    #   Mutex.new.synchronize do
    #     self.instance.stream_pid = fork {
    #       loop do
    #         sleep(Aro::Mancy::OS)

    #           Aos::S.say("processing streamq #{self.instance.q.inspect}...")
    #           Aos::Db.load
    #           next if Aos::Os.q.nil?
    #           qdup = Aos::Os.q.keys.dup
    #           qdup.each{|you_name|
    #             current_you = Aos::You.find_by(
    #               name: you_name
    #             )
    #             Aos::S.say("streaming #{Aos::Os.q[you_name].count} lines to #{current_you.name}")
    #             current_you.stream(
    #               Aos::Os.q.delete(you_name)
    #             )
    #           }
    #       end
    #     }
    #   end
    #   Process.detach(self.instance.stream_pid)
    #   File.open(Aos::Os.q_pid_file, "w") do |f|
    #     f.write(self.instance.stream_pid)
    #   end
    # end

    # def self.q_pid_file
    #   File.join(Aos::Cor.dom_cor_path, Aos::Os::Q_PID.to_s)
    # end

    # def self.q_up_file
    #   File.join(Aos::Cor.dom_cor_path, Aos::Os::Q_UP.to_s)
    # end

    # def self.read_q_up
    #   # return unless Aro::Dom.is_initialized?
    #   # Aos::You.pluck(:name).each{|you_name|
    #   #   q_up_file = Aos::Os.q_up_file_for_you(you_name)
    #   #   if File.exist?(q_up_file)
    #   #     self.instance.q[you_name] = JSON.parse(File.read(q_up_file))
    #   #   end
    #   # }
    # end

    # def self.write_q_up
    #   self.instance.q.keys.each{|you_name|
    #     File.open(Aos::Os.q_up_file_for_you(you_name), "w") do |q_up|
    #       q_up.write(self.instance.q[you_name].to_json)
    #     end
    #   }
    # end

    # def self.q_up_file_for_you(you_name)
    #   "#{you_name}.#{Aos::Os.q_up_file}"
    # end

    # def self.terminateq
    #   qpf = Aos::Os.q_pid_file
    #   if File.exist?(qpf)
    #     system("kill -9 #{File.read(qpf)}")
    #     FileUtils.rm(qpf)
    #     # Aos::Os.write_q_up
    #   end
    # end

    def handle_aro_override(args)
      return nil unless args[0].include?(:aro.to_s)
      # !self.you_flag.nil?
      yfi = args.index(Aos::Os::YOU_FLAG)
      if yfi.nil?
        args = "#{args.join(" ")} #{:aos.to_s} #{Aos::Os::YOU_FLAG} #{self.you.name}".split(" ")
      else
        args.insert(yfi, :aos.to_s)
      end

      `#{args.join(" ")}`
    end

    def process_cmd(cmd)
      # load config
      Aos::Cor.instance.load
      load_you!
      Dir.chdir(self.you.reload.pwd) do
        send_to_system_call = main(cmd)
        nothing = nil
        unless cmd.nil? || cmd.empty?
          nothing = handle_aro_override(cmd.split(" "))
          self.you.generate_ilog(cmd)
        end
        if send_to_system_call && nothing.nil?
          nothing = `#{cmd}`
        end

        unless nothing.nil?
          Aos::Os.say(nothing)
        else
          render
        end
      end

      CLI::EXIT_CODES[:SUCCESS]
    end

    def configure_readline(env)
      # case env
      # when :home
        Readline.completion_append_character = "/"
        Readline.completion_proc = Proc.new{|str|
          pwd = self.you_flag&.reload&.pwd || self.you&.reload&.pwd || ""
          dir_matcher = File.join(pwd, str + Aos::Os::STAR.to_s)
          # Aro::V.say(dir_matcher)
          dir_listing = Dir.glob(dir_matcher, File::FNM_DOTMATCH).map{|d| Aos::Os.osify(d).split("/").reject{|p| pwd.include?(p)}.join("/")}
          # Aro::V.say(dir_listing)
          dir_listing.grep(/^#{Regexp.escape(str)}/)
        }
      # when :aos
      #   Readline.completion_append_character = "/"
      #   Readline.completion_proc = Proc.new{|str|
      #     Aro::Dom::D.reserved_words.grep(/^#{Regexp.escape(str)}/)
      #   }
      # end
    end

    Mutex.new.synchronize do
      def run
        # run condition
        self.running = true

        # start cron
        Aos::Os.cron

        original_stdout = $stdout
        $stdout = StringIO.open do |out|
          cmd = nil

          loop do
            configure_readline :aos
            break unless self.running && cmd = Readline.readline(calc_ps1)
            IO.console.erase_screen(Aro::Mancy::S)
            height, width = IO.console.winsize
            IO.console.goto(height, Aro::Mancy::O)
            process_cmd(cmd)
          end

          out
        end

        CLI::EXIT_CODES[:SUCCESS]
      ensure
        $stdout = original_stdout
      end
    end

    def main(cmd)
      # begin game loop
      return false if cmd.nil?

      # get args
      args = cmd.split(" ")
      return false if args[0].nil?
      return false if args[0] == :aos.to_s

      # if self.you.home? && self.you.user?
      #   configure_readline :home
      #   self.display_lines = [`#{cmd}`]
      #   # render

      #   return false
      # end

      # send to "system" call in process_cmd method
      # if args[Aro::Mancy::O] is not in Aos::Os::CMDS
      send_to_system_call = !Aos::Os.is_aos_command?(args[Aro::Mancy::O])

      # the command is valid
      unless send_to_system_call

        Dir.chdir(self.you.pwd) do
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
          when Aos::Os::CMDS[:COR][:key]
            # config
            send_to_system_call = true
            Aos::Cor.process_command(args)
          when Aos::Os::CMDS[:DATA][:key]
            # data
            send_to_system_call = Aos::Data.process_cmd(args)
          when Aos::Os::CMDS[:EXIT][:key]
            # exit
            send_to_system_call = true
            handle_exit(args)
          when Aos::Os::CMDS[:FLIE][:key]
            # amg
            send_to_system_call = Aos::Flie.process_cmd(args)
          when Aos::Os::CMDS[:HELP][:key]
            # help
            send_to_system_call = handle_help(args)
          when Aos::Os::CMDS[:LL][:key]
            # ll
            send_to_system_call = false
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
      self.you_flag.nil? ? Aos::Os::PS1.to_s : ">[#{self.you_flag.name}]>: "
    end

    def redirect_to_room(arg)
      # search for reserved room path
      handled = false
      if arg.to_sym == Aro::Dom::COR
        handled = true
        self.you.home!
      else
        room_path = Aro::Dom.room_path(arg)
        if !self.you.root? &&
          room_path.include?(Aro::Dom::ROOT.to_s)
          self.display_lines = ["invalid access to #{room_path}. doing nothing."]
        elsif !room_path.empty?
          handled = true
          if room_path == Aro::Dom::HOME.to_s
            self.you.home!
          else
            Aro::D.say("#{__method__}#{Aos::Os::A}#{room_path}")
            self.you.update(pwd: File.join(
              Aro::Dom.dom_root,
              room_path
            ))
          end
        end
      end
      handled
    end

    def handle_help(args)
      redirect_to_room(Aro::Dom::WAITE)
      return false
    end

    def handle_ls(args)
      args = Aos::Os.sanitize_you(args)
      self.display_lines = [get_ls(args)]
    end

    def get_ls(args, split = false)
      "\n" + Dir.glob(
        File.join(
          self.you.pwd,
          (args[1] || "") + Aos::Os::STAR.to_s
        ),
        File::FNM_EXTGLOB
      ).map{|p|
        ">/" + Aos::Os::osify(p)
      }.join("\n")
    end

    def handle_ll(args)
      args = Aos::Os.sanitize_you(args)
      self.display_lines = [Dir.glob(File.join(self.you.pwd, (args[1] || "") + Aos::Os::STAR.to_s), File::FNM_DOTMATCH).map{|p| Aos::Os::osify(p.strip, true)}.join("\n")]
    end

    def handle_pwd(args)
      osified = "/" + Aos::Os::osify(self.you.pwd)
      self.display_lines = [osified]
    end

    def handle_exit(args)
      Aos::Os.say(["#{Aos::Os} is exiting..."])
      begin
        Aos::Abot.terminate
        Aos::Os.terminateq
      rescue StandardError => e
        Aro::D.say(e)
      end
      self.running = false
    end

    def handle_new_pwd(new_pwd)
      if !you.root? &&
        new_pwd.include?(Aro::Dom::ROOT.to_s)
        self.display_lines = ["invalid access to #{Aos::Os.osify(new_pwd)}. doing nothing."]
      elsif Aos::Os.osify(new_pwd) == Aro::Dom::HOME.to_s
        self.you.home!
      else
        Aro::V.say("new_pwd: #{new_pwd}")
        self.you.update(pwd: new_pwd)
      end
    end

    def handle_cd(args)
      args = Aos::Os.sanitize_you(args)
      if args[1].nil? || args[1] == "~/"
        # no arg takes you to arodom root
        self.you.update(pwd: File.dirname(Aro::Dom.ethergeist_path))
      else
        if args[1].include?(Aro::Dom::DOTT.to_s)
          # going up
          if File.dirname(Aro::Dom.ethergeist_path) == self.you.pwd
            self.display_lines = ["within #{Aos::Os}, one cannot leave the #{Aro::Dom}."]
          else
            # todo: support dots in paths
            # this only supports moving one level up

            pwd_arr = self.you.pwd.split("/")
            new_pwd = (pwd_arr.first(pwd_arr.length - 1)).join("/")

            handle_new_pwd(new_pwd)
          end
        else
          # this particular block needs to be better
          if args[1][0] == "/"
            args[1] = args[1][1..]
            new_pwd = File.join(Aro::Dom.dom_root, args[1])
            if Dir.exist?(new_pwd)
              handle_new_pwd(new_pwd)
            end
          elsif Dir.exist?(args[1]) && args[1] != Aro::Dom::DOT.to_s
            new_pwd = File.join(self.you.pwd, args[1])
            handle_new_pwd(new_pwd)
          else
            self.display_lines = ["that directory is invalid."]
          end
        end
      end
    end
  end
end

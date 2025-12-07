=begin

  aos.rb

  aos.

  by i2097i

=end

require :aro.to_s

module Aos

  def self.run
    Aos::Os::boot(Aos::you)
    Aos::Os.instance.run
  end

  def self.watch
    Aos::Os::boot(Aos::you)
    Aos::Os::instance.render
  end

  def self.you
    Aos::Db.new
    you = Aos::You.where(name: :you).first
    if you.nil?
      you = Aos::You.new(name: :you, pwd: Dir.pwd)
      you.save
    end

    you
  end

  class Os
    include Singleton

    attr_accessor :you, :running, :view

    PS1 = "@#{Aos::Os}$"

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
            description: I18n.t("aos.commands.description.config_set"),
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

    def load_view
      view_name = Aos::Os.osify(you.pwd).split("/").last || :dom.to_s
      view_cls = (Aos::Vi.name + "::#{view_name.capitalize}").constantize
      Aro::D.say("loading view #{view_cls}")
      self.view = view_cls
    end

    def render
      return if view.nil?

      view.show(you)
    end

    def run
      self.running = true

      # begin game loop
      while running do
        # get input
        cmd = Aos::S.p.ask(Aos::Os::PS1)

        # default to passthrough
        passthrough = true

        # get args
        args = cmd.split(" ")

        # search for room path
        room_path = Aro::Dom.room_path(args[0])
        if !room_path.empty?
          you.update(pwd: File.join(
            File.dirname(Aro::Dom.ethergeist_path),
            room_path
          ))
          Dir.chdir(you.pwd)
          next
        end

        # determine if command is Aos::Os::CMDS
        if Aos::Os::CMDS.values.map{|v| v[:key]}.include?(args[0].to_sym)
          Dir.chdir(you.pwd)
          passthrough = false
        end

        # config commands

        if args[0].to_sym == Aos::Os::CMDS[:CONFIG][:key]
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
            Aos::S.say("not implemented.")
          end
        elsif args[0] == Aos::Os::CMDS[:LS][:key].to_s
          Aos::S.say(Dir[File.join(Dir.pwd, "*/")].map{|p| "@/" + Aos::Os::osify(p)}.join("\n"))
        elsif args[0] == Aos::Os::CMDS[:PWD][:key].to_s
          osified = "@/" + Aos::Os::osify(you.pwd)
          Aos::S.say(osified)
        elsif args[0] == Aos::Os::CMDS[:EXIT][:key].to_s
          Aos::S.say("exiting...")
          self.running = false
        elsif args[0] == Aos::Os::CMDS[:CD][:key].to_s

          if args[1].nil? || args[1] == "~/"
            # no arg takes you to arodom root
            you.update(pwd: File.dirname(Aro::Dom.ethergeist_path))
          else
            if args[1].include?("..")
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
            elsif !args[1].nil?
              if args[1][0] != "/" && Dir.exist?(args[1])
                you.update(pwd: File.join(you.pwd, args[1]))
              else
                Aos::S.say("that directory is invalid.")
              end
            end
          end
        end

        if passthrough
          system(cmd)
        end
      end

      CLI::EXIT_CODES[:SUCCESS]
    end

    def self.osify(path)
      # strips off non-arodom part of path
      # Aos::Os::osify()

      path_arr = path.split("/")
      Aro::Dom::dom_root.split("/").each{|rdp|
        path_arr.delete(rdp)
      }

      path_arr.join("/")
    end
  end
end

=begin
  
  d.rb

  aro and dom.

  by i2097i

=end

module Aro
  class Dom
    include Singleton

    attr_accessor :eg_path, :is_initializing

    PS1 = :">[#{Aro::Dom.name}]>:"
    DOT = :"."
    DOTT = :"#{DOT}#{DOT}"
    ETHERGEIST = :eg
    ETHER_FILE = :".#{Aro::Dom::ETHERGEIST}"

    # < aro space
    ARODOME = :arodome

    # < user spaces
    WELCOME = :welcome
    GAMES = :games
    HOME = :home
    KNOW = :know
    ROOT = :root

    # > welcome spaces
    WAITE = :waite
    WINNER = :winner
    
    # > game spaces
    ABOT = :abot

    # > know spaces
    BODY = :body
    MIND = :mind
    SPIRIT = :spirit
    # ...

    # > root spaces
    AMG = :amg
    COR = :cor
    DATA = :data
    FLIE = :flie
    # ...

    def initialize
      self.is_initializing = false
    end

    def self.create(name)
      if Dir.exist?(name) || File.exist?(name)
        Aro::Dom::P.say(I18n.t("dom.errors.failed_directory_exists", name: name))
        return
      end

      Aro::Dom::P.say(I18n.t("dom.messages.creating_arodome", name: name))
      FileUtils.mkdir(name)
      ether_file_path = "#{name}/#{Aro::Dom::ETHER_FILE}"
      FileUtils.mkdir(ether_file_path)
      File.open(File.join(ether_file_path, Aro::Mancy::NAME_FILE.to_s), "w+") do |file|
        file.write(name)
      end

      Aro::Dom::P.say(I18n.t("dom.messages.arodome_created", name: name))
    end

    def self.in_arodom?
      !Aro::Dom.ethergeist_path.nil?
    end

    def self.is_initialized?
      return false if !Aro::Dom.in_arodom? || self.instance.is_initializing

      File.exist?(
        File.join(
          Aro::Dom.dom_root,
          Aro::Dom.room_path(:data),
          Aos::Db::SQL_FILE.to_s
        )
      )
    end

    def self.domain
      "#{Aos::Os.instance.you.nil? ? Aro::Dom : Aos::Os.instance.you.name}#{Aos::Os::A}#{Aro::Dom.ethergeist_name}"
    end

    def self.dom_root
      Aro::Dom.in_arodom? ? File.dirname(Aro::Dom::ethergeist_path) : nil
    end

    def self.room_path(needle)
      return nil if needle.nil?
      needle = needle.to_s.strip
      found_space = nil
      found_room = nil
      Aro::Dom::D::LAYOUT.values.each{|layout|
        next unless found_room.nil?
        found_space = layout[:name].to_s
        if found_space == needle
          found_room = found_space
          found_space = nil
        else
          layout[:rooms].each{|room|
            if room[:name].to_s == needle
              found_room = room[:name].to_s
            end
          }
        end
      }
      found_space = nil if found_room.nil?
      [found_space, found_room].compact.join("/")
    end

    def self.ethergeist_path
      if self.instance.eg_path.nil?
        path = nil
        search_path = Dir.pwd.split("/").reject{|p| p.empty?}
        search_pwd = "/"
        search_path.any?{|step|
          search_pwd = File.join(search_pwd, step)
          ls = Dir.glob("#{search_pwd}/#{ETHER_FILE}", File::FNM_DOTMATCH)

          path = ls.first if ls.any?
          !path.nil?
        }

        self.instance.eg_path = path unless path.nil?
      end

      return self.instance.eg_path
    end

    def self.ethergeist_name
      return nil unless Aro::Dom.in_arodom?

      File.read(
        File.join(
          Aro::Dom.ethergeist_path, Aro::Mancy::NAME_FILE.to_s
        )
      )
    end

    def generate(r_you, r_password)
      if r_you.nil? || r_you.empty?
        Aro::Dom::P.say(I18n.t("dom.messages.missing_root_username"))
        return
      end

      if r_password.nil? || r_password.empty?
        Aro::Dom::P.say(I18n.t("dom.messages.missing_root_password"))
        return
      end

      unless Aro::Dom.in_arodom?
        Aro::Dom::P.say(I18n.t("dom.errors.failed_already_initialized"))
        return
      end

      self.is_initializing = true
      Aro::Dom::P.say(I18n.t("dom.messages.generating_wings"))
      Aro::Dom::D::LAYOUT.values.each{|w| generate_wing w}
      # generate a dom aro instance and teck named same as dom
      Dir.chdir(Aro::Dom.ethergeist_path) do
        Aro::Dom::P.say(I18n.t("dom.messages.generating_dom_aro"))
        Aro::Mancy.init
        Aro::Teck.select_teck(
          Aro::Teck.make(Aro::Dom.ethergeist_name)
        )
      end
      Aos::Db.load(r_password)
      Aos::You.create(name: r_you, access: :root)
      Aro::Dom::P.say(I18n.t("dom.messages.initialization_complete", name: Aro::Dom.name))
      # todo: make this better and make an initial commit
      system(:"git init".to_s) if `which git`&.strip&.split("/")&.include?(:git.to_s)

      self.is_initializing = false
    end

    def generate_wing(wing)
      return unless Aro::Dom::D::LAYOUT.values.include?(wing)
      Aro::Dom::P.say(I18n.t("dom.messages.generating_wing", wing: wing[:name].to_s))
      FileUtils.mkdir(wing[:name].to_s)

      wing[:rooms].each{|r| generate_room(wing, r)}
    end

    def generate_room(wing, room)
      return unless Aro::Dom::D::WINGS[wing[:name].upcase].values.include?(room) ||
        wing[:name] == Aro::Dom::HOME

      Aro::Dom::P.say(I18n.t("dom.messages.generating_room", room: room[:name].to_s))

      r_path = File.join(wing[:name].to_s, room[:name].to_s)
      FileUtils.mkdir(r_path)

      if wing[:name] == Aro::Dom::GAMES
        File.open(File.join(r_path, Aro::Mancy::NAME_FILE.to_s), "w") do |f|
          f.write(room[:name])
        end
      end
    end

    def generate_agodo_home(agodo)
      Aro::Dom::P.say(I18n.t("dom.messages.generating_agodo_home", name: agodo.you.name))
      FileUtils.mkdir_r(agodo.home)
    end
  end
end

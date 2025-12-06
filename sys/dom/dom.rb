=begin
  
  d.rb

  aro and dom.

  by i2097i

=end

require_relative :"../aos/s".to_s

module Aro
  class Dom
    PS1 = :">[#{Aro::Dom.name}]>: "
    DOT = :"."
    DOTT = :"#{DOT}#{DOT}"
    ETHERGEIST = :ethergeist
    ETHER_FILE = :".#{Aro::Dom::ETHERGEIST}"

    # < root space
    ARODOME = :arodome

    # < user spaces
    WELCOME = :welcome
    GAMES = :games
    KNOW = :know
    SETUP = :setup

    # > welcome spaces
    WAITE = :waite
    WINNER = :winner
    
    # > game spaces
    ABPPS = :abpps
    HBPPS = :hbpps
    SHPPS = :shpps
    VIPPS = :vipps

    # > know spaces
    LIBRARY = :library
    TEMPLE = :temple
    # ...

    # > setup spaces
    CONFIG = :config
    AMG = :amg
    # ...

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
      return false if !Aro::Dom.in_arodom?

      File.exist?(File.join(Aro::Dom::ethergeist_path, Aos::Db::SQL_FILE.to_s))
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
      path = nil
      search_path = Dir.pwd.split("/").reject{|p| p.empty?}
      search_pwd = "/"

      search_path.any?{|step|
        search_pwd = File.join(search_pwd, step)
        ls = Dir.glob("#{search_pwd}/#{ETHER_FILE}", File::FNM_DOTMATCH)

        path = ls.first if ls.any?
        !path.nil?
      }

      return path
    end

    def self.ethergeist_name
      return nil unless Aro::Dom.in_arodom?

      File.read(
        File.join(
          Aro::Dom.ethergeist_path, Aro::Mancy::NAME_FILE.to_s
        )
      )
    end

    def generate
      return unless Aro::Dom.in_arodom?

      # todo: add file permissions to Aro::Dom::ARODOME and all WINGS
      Aro::Dom::P.say(I18n.t("dom.messages.generating_wings"))
      Aro::Dom::D::LAYOUT.values.each{|w| generate_wing w}
      Aos::Db::new
      Aro::Dom::P.say(I18n.t("dom.messages.initialization_complete", name: Aro::Dom.name))
    end

    def generate_wing(wing)
      return unless Aro::Dom::D::LAYOUT.values.include?(wing)
      Aro::Dom::P.say(I18n.t("dom.messages.generating_wing", wing: wing[:name].to_s))
      FileUtils.mkdir(wing[:name].to_s)

      wing[:rooms].each{|r| generate_room(wing, r)}
    end

    def generate_room(wing, room)
      return unless Aro::Dom::D::WINGS[wing[:name].upcase].values.include?(room)

      Aro::Dom::P.say(I18n.t("dom.messages.generating_room", room: room[:name].to_s))

      room_path = File.join(wing[:name].to_s, room[:name].to_s)
      FileUtils.mkdir(room_path)

      if wing[:name] == Aro::Dom::GAMES
        File.open(File.join(room_path, Aro::Mancy::NAME_FILE.to_s), "w") do |f|
          f.write(room[:name])
        end
      end
    end

    def self.ethergeist_name
      File.read(
        File.join(
          Aro::Dom.ethergeist_path, Aro::Mancy::NAME_FILE.to_s
        )
      )
    end
  end 
end # aroadhome

=begin
  
  d.rb

  aro and dom.

  by i2097i

=end

require_relative :"../aos/s".to_s

module Aro
  class Dom
    PS1 = Aro::Dom.name
    DOT = :"."
    DOTT = :"#{DOT}#{DOT}"
    ETHERGEIST = :ethergeist
    ETHER_FILE = :".#{Aro::Dom::ETHERGEIST}"

    # < root found_space
    ARODOME = :arodome

    # < user found_spaces
    WELCOME = :welcome
    GAMES = :games
    KNOW = :know
    SETUP = :setup

    # > welcome found_spaces
    WAITE = :waite
    WINNER = :winner
    
    # > game found_spaces
    ABPPS = :abpps
    HBPPS = :hbpps
    SHPPS = :shpps
    VIPPS = :vipps

    # > know found_spaces
    LIBRARY = :library
    TEMPLE = :temple
    # ...

    # > setup found_spaces
    SETTINGS = :settings
    # ...

    def self.create(name)
      if Dir.exist?(name) || File.exist?(name)
        # todo: i18n
        Aro::Dom::P.say("unable to create arodome at #{name}. file or directory already exists.")
      end

      # todo: i18n
      Aro::Dom::P.say("creating arodome named #{name}")
      FileUtils.mkdir(name)
      ether_file_path = "#{name}/#{Aro::Dom::ETHER_FILE}"
      FileUtils.mkdir(ether_file_path)
      File.open(File.join(ether_file_path, Aro::Mancy::NAME_FILE.to_s), "w+") do |file|
        file.write(name)
      end

      # todo: i18n
      Aro::Dom::P.say("#{name} arodome created. enter the following commands to begin.")
      Aro::Dom::P.say("$ cd #{name}")
      Aro::Dom::P.say("$ aro dom init")
    end

    def self.in_arodom?
      !Aro::Dom.ethergeist_path.nil?
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

    def self.dom_root
      File.dirname(Aro::Dom::ethergeist_path)
    end

    def generate
      return unless Aro::Dom.in_arodom?

      # todo: add file permissions to Aro::Dom::ARODOME and all WINGS

      Aro::Dom::P.say("generating wings...")
      Aro::Dom::D::LAYOUT.values.each{|w| generate_wing w}
      
      Aro::Dom::P.say("#{Aro::Dom.name} initialization complete!")
    end

    def generate_wing(wing)
      return unless Aro::Dom::D::LAYOUT.values.include?(wing)

      Aro::Dom::P.say("generating the #{wing[:name]} wing...")
      FileUtils.mkdir(wing[:name].to_s)

      wing[:rooms].each{|r| generate_room(wing, r)}
    end

    def generate_room(wing, room)
      return unless Aro::Dom::D::WINGS[wing[:name].upcase].values.include?(room)

      Aro::Dom::P.say("generating the #{room[:name]} room.")

      room_path = File.join(wing[:name].to_s, room[:name].to_s)
      FileUtils.mkdir(room_path)

      if wing[:name] == Aro::Dom::GAMES
        File.open(File.join(room_path, Aro::Mancy::NAME_FILE.to_s), "w+") do |f|
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

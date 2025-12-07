=begin
  
  d.rb

  aro and dom.

  by i2097i

=end

require_relative :"./s".to_s

module Aro
  class Dom
    PS1 = Aro::Dom.name
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

    def self.ethergeist_path
      root = nil
      pwd_path = Dir.pwd.split("/").reject{|p| p.empty?}
      pwd = "/"

      pwd_path.any?{|step|
        pwd = File.join(pwd, step)
        ls = Dir.glob("#{pwd}/#{ETHER_FILE}", File::FNM_DOTMATCH)
        
        root = ls.first if ls.any?
        !root.nil?
      }

      return root
    end

    def dom_root
      # todo:
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

    def self.map
      return unless Aro::Dom.in_arodom?

      dc = CLI::Config.display_config
      width = dc[:WIDTH]
      divider = dc[:DIVIDER] * width + "\n"

      map_name = File.read(
        File.join(
          Aro::Dom.ethergeist_path, Aro::Mancy::NAME_FILE.to_s
        )
      )

      Aro::V.say("map_name: #{map_name}")

      Aro::Mancy::OS.times do
        Aro::Aos::S.say(divider)
      end
      # center the title
      t_divider = dc[:DIVIDER] * ((width - map_name.length) / Aro::Mancy::OS)
      Aro::Aos::S.say((t_divider + map_name).ljust(width, dc[:DIVIDER]))
      Aro::Mancy::OS.times do
        Aro::Aos::S.say(divider)
      end

      empty_s = " "
      bar = "|" * Aro::Mancy::OS

      # make this configurable via env var
      this should not run until completed.
      Aro::Mancy::NUMERALS[:XLII].times do |i|

        inject = "#{i.to_s.ljust(Aro::Mancy::OS)}) #{Aro::Mancy::PS1}$ "

        case i
        when Aro::Mancy::O
          # width.times do |r|
            # inject += "".ljust(width - (bar.length * Aro::Mancy::N.pow(Aro::Mancy::OS)), "#{Aro::Mancy::O}")
            inject += "hello world."
          # end
        when Aro::Mancy::S
          inject += "if you've found your way here then you are well on your way to becoming an aromancer."
        when Aro::Mancy::OS
          inject += "it's like terminal but much more fun because we dip into the realm of chance as a rule."
        when Aro::Mancy::NUMERALS[:III]
          inject += "this will help us begin to understand such things with greater depths."
        when Aro::Mancy::N
          inject += "in any case, welcome to the #{Aro::Mancy} #{Aro::Dom} that you have so graciously named '#{map_name.downcase}'."
        end
        Aro::Aos::S.say((bar + inject).ljust(width) + bar)
      end

      Aro::Mancy::N.times do
        Aro::Aos::S.say(divider)
      end
    end
  end 
end # aroadhome

=begin

=end

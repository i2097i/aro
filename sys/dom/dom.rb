=begin
  
  d.rb

  aro and dom.

  by i2097i

=end

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
      pwd_path = Dir.pwd.split("/").reject{|p| p.empty?}
      pwd = "/"

      pwd_path.any?{|step|
        pwd = File.join(pwd, step)
        puts "checking #{pwd}"
        ls = Dir.glob("#{pwd}/#{ETHER_FILE}", File::FNM_DOTMATCH)
        ls.any?
      }
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
      FileUtils.mkdir(File.join(wing[:name].to_s, room[:name].to_s))
    end
  end
end # aroadhome

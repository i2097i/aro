=begin
  
  aro.rb

  aro and mancy.

  by i2097i

=end

module Aro
  class Mancy
    include Singleton

    attr_accessor :game

    O  = 0
    S  = 1
    OS = 2
    E  = 3
    N  = 4
    V  = 5
    PS1 = :">[#{Aro::Mancy.name}]>: "
    NAME_FILE = :".name"
    ARO_FILE = :".aro"
    I2097I = :i2097i
    YES = :aroyes
    ALL = :all

    ARO_ENV_DEBUG_MODES = [:development, :test]

    NUMERALS = {
      O:       0,
      I:       1,
      II:      2,
      III:     3,
      IV:      4,
      V:       5,
      VI:      6,
      VII:     7,
      VIII:    8,
      IX:      9,
      X:       10,
      XI:      11,
      XII:     12,
      XIII:    13,
      XIV:     14,
      XV:      15,
      XVI:     16,
      XVII:    17,
      XVIII:   18,
      XIX:     19,
      XX:      20,
      XXI:     21,
      XXII:    22,
      XXXVII:  37,
      XLII:    42,
      LX:      60,
      C:       100,
      MMXCVII: Aro::Mancy::I2097I[Aro::Mancy::S..Aro::Mancy::N].to_i,
    }

    def initialize
      if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
        Aro::Config.instance.load
        Aro::Mancy.init
        self.game = Aro::Teck.current_teck
      end
    end

    def self.game
      Aro::Mancy.instance.game
    end

    def self.create(name)
      return false if Aro::Mancy.in_aro? || name.nil?

      # explicitly only allow String/Symbol types for name
      return false unless name.kind_of?(String) || name.kind_of?(Symbol)
      name = name.to_s.strip
      
      # create the new aro directory and database
      if !Dir.exist?(name)
        Aro::P.say(I18n.t("cli.messages.no_tecks"))
        FileUtils.mkdir(name)
      else
        return false
      end

      # create name file
      File.open(File.join(name, Aro::Mancy::NAME_FILE.to_s), "w+") do |file|
        file.write(name)
      end

      Dir.chdir(name) do
        Aro::Mancy.init
      end
      return true
    end

    def self.init
      Aro::Db.load
    end

    def self.is_initialized?
      !Aro::Db.base_aro_dir.nil? && Dir.exist?(Aro::Db.base_aro_dir)
    end

    def self.in_aro?
      File.exist?(Aro::Mancy::NAME_FILE.to_s)
    end

    def self.domain
      "#{Aro::Mancy}#{Aos::Os::A}#{Aro::Mancy.aro_mancy_name}"
    end

    def self.aro_mancy_name
      return nil unless Aro::Mancy.in_aro?

      File.read(Aro::Mancy::NAME_FILE.to_s).strip
    end
  end
end

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
    N  = 4
    PS1 = Aro::Mancy.name
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
      XLII:    42,
      MMXCVII: Aro::Mancy::I2097I[Aro::Mancy::S..Aro::Mancy::N].to_i,
    }

    def initialize
      # ENV bindings
      ENV[:ARO_ENV_O.to_s] = "#{Aro::Mancy::O}"
      ENV[:ARO_ENV_S.to_s] = "#{Aro::Mancy::S}"
      ENV[:ARO_ENV_OS.to_s] = "#{Aro::Mancy::OS}"
      ENV[:ARO_ENV_N.to_s] = "#{Aro::Mancy::N}"
      ENV[:ARO_ENV_PS1.to_s] = "#{Aro::Mancy::PS1}"
      ENV[:ARO_ENV_NAME_FILE.to_s] = "#{Aro::Mancy::NAME_FILE}"
      ENV[:ARO_ENV_I2097I.to_s] = "#{Aro::Mancy::I2097I}"
      ENV[:ARO_ENV_YES.to_s] = "#{Aro::Mancy::YES}"
      ENV[:ARO_ENV_ALL.to_s] = "#{Aro::Mancy::ALL}"

      if Aro::Mancy.is_aro_space? && Aro::Mancy.is_initialized?
        Aro::Mancy.init
        self.game = Aro::Deck.current_deck
      end
    end

    def self.game
      Aro::Mancy.instance.game
    end

    def self.create(name)
      return false if Aro::Mancy.is_aro_space? || name.nil?

      # explicitly only allow String/Symbol types for name
      return false unless name.kind_of?(String) || name.kind_of?(Symbol)
      name = name.to_s.strip
      
      # create the new aro directory and database
      if !Dir.exist?(name)
        Aro::P.say(I18n.t("cli.messages.no_decks"))
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
      Aro::Db.new
    end

    def self.is_initialized?
      Dir.exist?(Aro::Db.base_aro_dir)
    end

    def self.is_aro_space?
      File.exist?(Aro::Mancy::NAME_FILE.to_s)
    end
  end
end

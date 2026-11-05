=begin
  
  aro.rb

  aro and mancy.

  by i2097i

=end

module Aro
  class Mancy
    include Singleton

    attr_accessor :current

    A  = :"@"
    O  = 0
    S  = 1
    OS = 2
    E  = 3
    N  = 4
    V  = 5
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"
    NAME_FILE = :".aro_space"
    ARO_FILE = :".aro"
    I2097I = :i2097i
    YES = :aroyes
    ALL = :all

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

    def self.teck
      if Aro::Mancy.in_aro? && Aro::Mancy.is_initialized?
        self.instance.current = Aro::Teck.current_teck
      end
      self.instance.current
    end

    def self.create(aro_name, is_test: false)
      return false if (!is_test && Aro::Mancy.in_aro?) ||
        aro_name.nil?

      # explicitly only allow String/Symbol types for name
      return false unless aro_name.kind_of?(String) || aro_name.kind_of?(Symbol)
      aro_name = aro_name.to_s.strip
      # create the new aro directory and database
      if !Dir.exist?(aro_name)
        Aro::P.say(I18n.t("messages.no_tecks"))
        FileUtils.mkdir(aro_name)
      end

      FileUtils.chdir(aro_name) do
        Aro::Mancy.init
        Aro::Cor.instance.load_env
      end
      return true
    end

    def self.init
      unless Aro::Mancy.in_aro? || Aro::Cor.is_test?
        Aro::P.say("init aro running in present directory...")
        new_name = File.basename(Dir.pwd)
        Aro::P.say("echo #{new_name} > #{Aro::Mancy::NAME_FILE.to_s}")
        File.open(Aro::Mancy::NAME_FILE.to_s, "w") do |file|
          file.write(new_name)
        end
      end

      Aro::Db.load
    end

    def self.is_initialized?
      !Aro::Db.base_aro_dir.nil? && Dir.exist?(Aro::Db.base_aro_dir)
    end

    def self.in_aro?
      File.exist?(Aro::Mancy::NAME_FILE.to_s)
    end

    def self.domain
      is_initialized? ? "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Mancy}" : `whoami`
    end

    def self.aro_mancy_name
      File.read(Aro::Mancy::NAME_FILE.to_s).strip
    end

    def self.ps1_display(cls_name = nil)
      :">[#{cls_name || Aro::Mancy.domain || aro_mancy_name}]>: ".to_s
    end
  end
end

# frozen_string_literal: true

=begin
  
  aro.rb

  aro and mancy.

  by i2097i

=end

#

module Aro
  class Mancy
    include Singleton
    A  = :"@"
    O  = 0
    S  = 1
    OS = 2
    E  = 3
    N  = 4
    V  = 5
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"
    NAME_FILE = :".oss_om_space"
    ARO_DIRECTORY = :".oss_om"

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

    def self.create(aro_name, is_test: false)
      Aro::D.say(__method__)
      Aro::D.say(:depricated)
      return true
    end

    def self.init(root_dir_path)
      unless Aro::Mancy.in_aro?
        Aro::P.say("init aro running in #{root_dir_path} directory...")
        new_name = File.basename(root_dir_path)
        Aro::P.say("echo #{new_name} > #{Aro::Mancy::NAME_FILE.to_s}")
        File.open(Aro::Mancy::NAME_FILE.to_s, "w") do |file|
          file.write(new_name)
          file.write("\n")
        end
      end
      return true
    end

    def self.root_dir
      ::File.join(
        Aro::Cor.ivar(:OSS_OM_HOME) || Dir.pwd,
        Aro::Mancy::ARO_DIRECTORY.to_s
      )
    end

    def self.is_initialized?
      in_aro? && Aro::Db.instance.connected?
    end

    def self.in_aro?
      File.exist?(Aro::Mancy::NAME_FILE.to_s)
    end

    def self.domain
      is_initialized? ? "#{Aro::Mancy.aro_mancy_name}#{Aro::Mancy::A}#{Aro::Mancy}" : `whoami`.strip
    end

    def self.aro_mancy_name
      File.read(Aro::Mancy::NAME_FILE.to_s).strip
    end

    def self.ps1_display(cls_name = nil)
      :">[#{cls_name || Aro::Mancy.domain || aro_mancy_name}]>: ".to_s
    end
  end
end

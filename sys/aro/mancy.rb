=begin
  
  aro.rb

  aro and mancy.

  by i2097i

=end

#

module Aro
  class Mancy
    include Singleton

    attr_accessor :current, :db_busy, :db_thread

    A  = :"@"
    O  = 0
    S  = 1
    OS = 2
    E  = 3
    N  = 4
    V  = 5
    DATE_FORMAT = "%A %d %b %Y %I:%M:%S %p"
    NAME_FILE = :".aro_space"
    ARO_DIRECTORY = :".aro"
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

    def initialize
      Aro::Dom::Ma_ain.instance.data_mutex.synchronize do
        # kick it off
        Thread.new do
          Aro::Db.ensure_connected!
        end

        # start monitoring
        self.start_db_thread
      end

      while self.db_thread.status.to_sym == :run ||
        !Aro::Db.instance.connected?
        sleep(0.1)
      end
    end

    def self.teck
      self.init
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
        FileUtils.mkdir(::File.join(self.root_dir, aro_name))
      end

      FileUtils.chdir(::File.join(self.root_dir, aro_name)) do
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
    end

    def self.root_dir
      return Dir.pwd unless in_aro?
      ::File.join(
        ::File.path(::File.basename(".")),
        Aro::Mancy::ARO_DIRECTORY.to_s
      )
    end

    def self.is_initialized?
      in_aro? && Dir.exist?(Aro::Mancy.root_dir)
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

    private

    def start_db_thread
      return if @db_busy
      @db_busy = true
      self.db_thread&.exit
      self.db_thread&.kill
      self.db_thread = Thread.new do
        loop do
          @db_busy = true
          Aro::Dom::Ma_ain.instance.data_mutex.synchronize do
            Aro::V.say(Aro::Mancy.instance.db_thread.inspect)
            Aro::V.say(__method__)
            Aro::Db.ensure_connected!
          end
          @db_busy = false
          sleep(Aro::Db::HEARTBEAT_DURATION)
        end
      end
    end

  end
end

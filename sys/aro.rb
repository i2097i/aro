=begin
  
  aro.rb

  aro and mancy.

  by i2097i

=end

require_relative :reiquire.to_s
Reiquire::aro

module Aro
  class Mancy
    include Singleton

    attr_accessor :game

    O = 0
    S = 1
    N = 4
    OS = 2
    PS1 = Aro::Mancy.name
    NAME_FILE = :".name"
    I2097I = :i2097i
    YES = :aroyes

    def initialize
      if Aro::Mancy.is_aro_space?
        Aro::Db.new
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

      return true
    end

    def self.is_aro_space?
      File.exist?(Aro::Mancy::NAME_FILE.to_s)
    end
  end
end

# TODO: this doesn't work
# require :"active_support/time_with_zone".to_s
# TODO: this doesn't work
  # Time.zone = ActiveSupport::TimeZone[Time.now.gmtoff].tzinfo.name
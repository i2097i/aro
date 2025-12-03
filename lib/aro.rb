# require aro directories
[
  :aro,
  :models,
].each{|dir|
  Dir[File.join(
    __dir__,
    dir.to_s,
    :"**/*.rb".to_s
  )].each { |file| require file}
}

module Aro
  class Mancy
    include Singleton

    attr_accessor :game

    def initialize
      Aro::Create.new(Aro::Db.get_name_from_namefile)
      self.game = Aro::Deck.current_deck
    end

    def self.game
      Mancy.instance.game
    end
  end

  ARO_PS1 = "#{Aro::Mancy.name}"
end

# TODO: this doesn't work
# require :"active_support/time_with_zone".to_s
# TODO: this doesn't work
  # Time.zone = ActiveSupport::TimeZone[Time.now.gmtoff].tzinfo.name
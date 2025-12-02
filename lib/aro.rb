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
      Aro::Create.new(Aro::Database.get_name_from_namefile)
      self.game = Aro::Deck.current_deck
    end

    def self.exit_error_missing_args!
      Aro::P.p.say(I18n.t("cli.errors.header"))
      Aro::P.p.say(I18n.t("cli.errors.missing_args", cmd: "#{CLI::ARGV0} #{CLI::ARGV1} #{CLI::ARGV2}"))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end

    def self.game
      Mancy.instance.game
    end
  end
end

# TODO: this doesn't work
# require :"active_support/time_with_zone".to_s
# TODO: this doesn't work
  # Time.zone = ActiveSupport::TimeZone[Time.now.gmtoff].tzinfo.name
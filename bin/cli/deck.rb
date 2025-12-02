=begin
  
  deck.rb

  process deck commands.

  by i2097i

=end

module CLI
  def self.deck
    action = CLI::ARGV1&.upcase&.to_sym

    if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
      CLI::usage
      exit(CLI::EXIT_CODES[:SUCCESS])
    elsif CLI::ARGV1.nil?
      # no args, open deck menu
      Aro::Create.new(Aro::Database.get_name_from_namefile)
      Aro::Deck.display_selection_menu
    elsif action == CLI::CREATE_DECK_ACTIONS[:CREATE]
      Aro::Mancy.exit_error_missing_args! if CLI::ARGV2.nil?
      deck = Aro::Deck.make(CLI::ARGV2.to_s)
      Aro::P.p.say(I18n.t("cli.messages.deck_created_sucessfully", name: deck.name))
      Aro::Deck.display_selection_menu
    elsif CLI::LOAD_DECK_ACTIONS.include?(action)
      deck = CLI::get_deck

      if action == CLI::LOAD_DECK_ACTIONS[:EXPLORE]
        deck.explore
      else
        # assume shuffle or show, in which case show is always called
        if action == CLI::LOAD_DECK_ACTIONS[:SHUFFLE]
          Aro::P.p.say(I18n.t("cli.messages.shuffling", name: deck.name))
          deck.shuffle
        elsif action == CLI::LOAD_DECK_ACTIONS[:DRAW]
          Aro::P.p.say(I18n.t("cli.messages.drawing", name: deck.name))
          deck.draw
        elsif action == CLI::LOAD_DECK_ACTIONS[:REPLACE]
          Aro::P.p.say(I18n.t("cli.messages.replacing_drawn", name: deck.name))
          deck.replace
        elsif action == CLI::LOAD_DECK_ACTIONS[:RESET]
          if Aro::AROYES != Aro::P.p.ask(I18n.t("cli.messages.confirmation_prompt", name: deck.name))
            Aro::P.p.say(I18n.t("cli.messages.understood", name: deck.name))
            exit(CLI::EXIT_CODES[:SUCCESS])
          end

          Aro::P.p.say(I18n.t("cli.messages.resetting", name: deck.name))
          deck.reset
        end

        Aro::P.p.say(I18n.t("cli.messages.showing", name: deck.name))
        deck.show
      end
    else
      CLI::usage
    end
  end

  def self.get_deck
    Aro::Create.new(Aro::Database.get_name_from_namefile)
    deck = nil
    if CLI::ARGV2.nil?
      # assume current deck
      deck = Aro::Deck.current_deck
    else
      deck = Aro::Deck.find_by(name: CLI::ARGV2)
      deck = Aro::Deck.find_by(id: CLI::ARGV2) if deck.nil?
    end

    if deck.nil?
      Aro::P.p.say(I18n.t("cli.errors.missing_deck", cmd: "#{CLI::ARGV0} #{CLI::ARGV1} #{CLI::ARGV2}"))
      exit(CLI::EXIT_CODES[:GENERAL_ERROR])
    end

    deck
  end
end

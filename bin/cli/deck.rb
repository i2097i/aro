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
      Deck.display_selection_menu
    elsif action == CLI::CREATE_DECK_ACTIONS[:CREATE]
      if CLI::ARGV2.nil?
        Aro::P.p.say(I18n.t("cli.errors.header"))
        Aro::P.p.say(I18n.t("cli.errors.missing_args", cmd: "#{ARGV0} #{ARGV1}"))
        exit(CLI::EXIT_CODES[:INVALID_ARG])
      end
      Aro::Create.new(Aro::Database.get_name_from_namefile)
      new_deck = Deck.create(name: CLI::ARGV2)
      if Deck.current_deck.nil?
        File.open(Deck::DECK_FILE, "w") do |file|
          file.write(new_deck.id)
        end
      end
      Aro::P.p.say(I18n.t("cli.messages.deck_created_sucessfully", name: CLI::ARGV2))
      Deck.display_selection_menu
    elsif CLI::LOAD_DECK_ACTIONS.include?(action)
      deck = CLI::get_deck

      if action == CLI::LOAD_DECK_ACTIONS[:EXPLORE]
        deck.explore
      else
        # assume shuffle or show, in which case show is always called
        if action == CLI::LOAD_DECK_ACTIONS[:SHUFFLE]
          deck.shuffle
        elsif action == CLI::LOAD_DECK_ACTIONS[:DRAW]
          deck.draw
        elsif action == CLI::LOAD_DECK_ACTIONS[:REPLACE]
          Aro::P.p.say("todo replace")
          exit(CLI::EXIT_CODES[:SUCCESS]) # remove this line when complete
        elsif action == CLI::LOAD_DECK_ACTIONS[:RESET]
          if Aro::AROYES != Aro::P.p.ask(I18n.t("cli.messages.confirmation_prompt"))
            Aro::P.p.say(I18n.t("cli.messages.understood"))
            exit(CLI::EXIT_CODES[:SUCCESS])
          end

          deck.reset
        end

        deck.history
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
      deck = Deck.current_deck
    else
      deck = Deck.find_by(name: CLI::ARGV2)
      deck = Deck.find_by(id: CLI::ARGV2) if deck.nil?
    end

    if deck.nil?
      Aro::P.p.say(I18n.t("cli.errors.missing_deck", cmd: "#{ARGV0} #{ARGV1} #{ARGV2}"))
      exit(CLI::EXIT_CODES[:GENERAL_ERROR])
    end

    deck
  end
end

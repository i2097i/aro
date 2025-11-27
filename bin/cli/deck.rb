=begin
	
	deck.rb

	process deck commands.

	by i2097i

=end

module CLI
	def self.deck
		action = CLI::ARGV1&.upcase.to_sym

	  if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
	    CLI::usage
	    exit(CLI::EXIT_CODES[:SUCCESS])
	  elsif CLI::ARGV1.nil?
	    # no args, open deck menu
	    Aro::Create.new(Aro::Database.get_name_from_namefile)
	    Deck.display_selection_menu
	  elsif action == CLI::CREATE_DECK_ACTIONS[:CREATE]
	    if CLI::ARGV2.nil?
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
	      cards = deck.cards.split(",").map{|c| [I18n.t("cards.#{c}.name"), c]}.to_h
	      answer = Aro::P.p.select(
	      	I18n.t("cli.messages.choose_card"),
	      	cards,
	      	per_page: 7,
	      	cycle: true,
	      	default: 1
	      )

	      # TODO: display this nicer
	      Aro::P.p.say(I18n.t("cards.#{answer}"))
	    elsif action == CLI::LOAD_DECK_ACTIONS[:HISTORY]
	    	deck.history
	    else
	    	# assume shuffle or show, in which case show is always called
	      if action == CLI::LOAD_DECK_ACTIONS[:SHUFFLE]
	        deck.shuffle
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

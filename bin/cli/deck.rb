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
      Aro::Create.new(Aro::Db.get_name_from_namefile)
      Aro::Deck.display_selection_menu
    elsif action == CLI::CREATE_DECK_ACTIONS[:CREATE]
      CLI::Aroface.exit_error_missing_args! if CLI::ARGV2.nil?
      deck = Aro::Deck.make(CLI::ARGV2.to_s)
      Aro::P.say(I18n.t("cli.messages.deck_created_sucessfully", name: Aro::Mancy.game.name))
      Aro::Deck.display_selection_menu
    elsif CLI::LOAD_DECK_ACTIONS.include?(action)    
      if Aro::Mancy.game.nil?
        Aro::P.say(I18n.t("cli.errors.missing_deck"))
        exit(CLI::EXIT_CODES[:GENERAL_ERROR])
      end

      case action
      when CLI::LOAD_DECK_ACTIONS[:EXPLORE]
        Aro::Mancy.game.explore
        exit(CLI::EXIT_CODES[:SUCCESS])
      when CLI::LOAD_DECK_ACTIONS[:SHUFFLE]
        Aro::P.say(I18n.t("cli.messages.shuffling", name: Aro::Mancy.game.name))
        Aro::Mancy.game.shuffle
      when CLI::LOAD_DECK_ACTIONS[:DRAW]
        Aro::P.say(I18n.t("cli.messages.drawing", name: Aro::Mancy.game.name))
        Aro::P.p.say(I18n.t("cli.messages.drawing_from_dimension", dimension: "#{CLI::Config.var_value_with_suffix(:DIMENSION)}"))
        Aro::Mancy.game.draw(
          is_dt_dimension: CLI::Config.var_value_with_suffix(:DIMENSION).to_sym == CLI::Config::DMS[:DEV_TAROT],
          z_max: CLI::Config.var_value_with_suffix(:Z_MAX).to_i,
          z: CLI::Config.var_value_with_suffix(:Z)
        )
      when CLI::LOAD_DECK_ACTIONS[:REPLACE]
        Aro::P.say(I18n.t("cli.messages.replacing_drawn", name: Aro::Mancy.game.name))
        Aro::Mancy.game.replace
      when CLI::LOAD_DECK_ACTIONS[:RESET]
        if Aro::AROYES != Aro::P.p.ask(I18n.t("cli.messages.confirmation_prompt", name: Aro::Mancy.game.name))
          Aro::P.say(I18n.t("cli.messages.understood", name: Aro::Mancy.game.name))
          exit(CLI::EXIT_CODES[:SUCCESS])
        end

        Aro::P.say(I18n.t("cli.messages.resetting", name: Aro::Mancy.game.name))
        Aro::Mancy.game.reset
      end

      Aro::Mancy.game.show(**CLI::Deck.shoptions)
    else
      CLI::usage
    end
  end

  module Deck

    # parse show options
    def self.shoptions
      show_options_count = Aro::Log::DEFAULT_COUNT
      show_options_order = Aro::Log::ORDERING[:DESC]
      
      # Aro::P.say("ARGV.map{|a| a.to_sym} => #{ARGV.map{|a| a.to_sym}}")
      
      count_option_flags = ARGV.map{|a| a.to_sym} & CLI::FLAGS[:SHOW_COUNT]
      # Aro::P.say("count_option_flags: #{count_option_flags}")
      if count_option_flags.any?
        # get the ARGV index element after flag index
        show_options_count = ARGV[ARGV.index(count_option_flags.first.to_s) + 1]
        show_options_count = show_options_count.to_i unless [0, nil].include?(show_options_count&.to_i)
        # Aro::P.say("show_options_count: #{show_options_count}")
      end

      order_option_flags = ARGV.map{|a| a.to_sym} & CLI::FLAGS[:SHOW_ORDER]
      # Aro::P.say("count_option_flags: #{order_option_flags}")
      if order_option_flags.any?
        # get the ARGV index element after flag index
        show_options_order = ARGV[ARGV.index(order_option_flags.first.to_s) + 1].upcase.to_sym
        Aro::P.say("show_options_order: #{show_options_order}")
      end

      {
        count_n: show_options_count,
        order_o: show_options_order
      }
    end

  end
end

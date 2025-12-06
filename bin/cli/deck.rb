=begin
  
  deck.rb

  process deck commands.

  by i2097i

=end

module CLI
  # cli entrypoint
  def self.deck
    action = CLI::ARGV1&.to_sym

    if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
      # todo: breakout usage into subcommand-specific verbiage
      CLI.usage::usage
      exit(CLI::EXIT_CODES[:SUCCESS])
    elsif CLI::ARGV1.nil?
      # no args, open deck menu
      Aro::Db.new
      Aro::Deck.display_selection_menu
    elsif action == CLI::CMDS[:DECK][:NEW]
      CLI::Nterface.exit_error_missing_args! if CLI::ARGV2.nil?
      deck = Aro::Deck.make(CLI::ARGV2.to_s)
      Aro::P.say(I18n.t("cli.messages.deck_created_sucessfully", name: Aro::Mancy.game.name))
      Aro::Deck.display_selection_menu
    elsif CLI::CMDS[:DECK].values.include?(action)    
      if Aro::Mancy.game.nil?
        Aro::P.say(I18n.t("cli.errors.missing_deck", cmd: Aro::Mancy::I2097I))
        exit(CLI::EXIT_CODES[:GENERAL_ERROR])
      end

      case action
      when CLI::CMDS[:DECK][:EXPLORE]
        Aro::Mancy.game.explore
        exit(CLI::EXIT_CODES[:SUCCESS])
      when CLI::CMDS[:DECK][:SHUFFLE]
        Aro::P.say(I18n.t("cli.messages.shuffling", name: Aro::Mancy.game.name))
        Aro::Mancy.game.shuffle
      when CLI::CMDS[:DECK][:DRAW]
        Aro::P.say(I18n.t("cli.messages.drawing", name: Aro::Mancy.game.name))
        Aro::P.say(I18n.t("cli.messages.drawing_from_dimension", dimension: "#{CLI::Config.cvar(:DIMENSION)}"))
        Aro::Mancy.game.draw(
          is_dt_dimension: CLI::Config.cvar(:DIMENSION)&.to_sym == CLI::Config::DMS[:DEV_TAROT],
          z_max: CLI::Config.cvar(:Z_MAX).to_i,
          z: CLI::Config.cvar(:Z)
        )
      when CLI::CMDS[:DECK][:REPLACE]
        Aro::P.say(I18n.t("cli.messages.replacing_drawn", name: Aro::Mancy.game.name))
        Aro::Mancy.game.replace
      when CLI::CMDS[:DECK][:RESET]
        if Aro::Mancy::YES.to_s != Aro::P.p.ask(I18n.t("cli.messages.confirmation_prompt", name: Aro::Mancy.game.name))
          Aro::P.say(I18n.t("cli.messages.understood", name: Aro::Mancy.game.name))
          exit(CLI::EXIT_CODES[:SUCCESS])
        end

        Aro::P.say(I18n.t("cli.messages.resetting", name: Aro::Mancy.game.name))
        Aro::Mancy.game.reset
      end

      Aro::Mancy.game.show(**CLI::shoptions)
    end
  end
  
  # parse show options
  # todo: better naming
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
      show_options_order = ARGV[ARGV.index(order_option_flags.first.to_s) + 1].to_sym
      Aro::P.say("show_options_order: #{show_options_order}")
    end

    {
      count_n: show_options_count,
      order_o: show_options_order
    }
  end

end

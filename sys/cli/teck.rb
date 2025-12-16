=begin
  
  teck.rb

  process teck commands.

  by i2097i

=end

module CLI
  # cli entrypoint
  def self.teck
    action = CLI::ARGV1&.to_sym

    if CLI::FLAGS[:HELP].include?(action.to_s)
      # todo: breakout usage into subcommand-specific verbiage
      CLI.usage::usage
      exit(CLI::EXIT_CODES[:SUCCESS])
    elsif action.nil? || action == :aos
      # no args, open teck menu
      if Aro::Mancy.in_aro?
        Aro::Db.load
        Aro::Teck.display_selection_menu
      else
        Aro::P.say(I18n.t("cli.errors.not_in_aro" , cmd: Aro::Mancy::I2097I))
      end
    elsif action == CLI::CMDS[:DECK][:NEW]
      CLI::Nterface.exit_error_missing_args! if CLI::ARGV2.nil?
      if Aro::Mancy.in_aro?
        Aro::Db.load
        teck = Aro::Teck.make(CLI::ARGV2.to_s)
        Aro::P.say(I18n.t("cli.messages.teck_created_sucessfully", name: teck.name))
        Aro::Teck.display_selection_menu
      else
        Aro::P.say(I18n.t("cli.errors.not_in_aro" , cmd: Aro::Mancy::I2097I))
      end
    elsif CLI::CMDS[:DECK].values.include?(action)    
      if Aro::Mancy.game.nil?
        Aro::P.say(I18n.t("cli.errors.missing_teck", cmd: Aro::Mancy::I2097I))
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
        Aro::P.say(I18n.t("cli.messages.drawing_from_dimension", dimension: "#{Aro::Config.ivar(:DIMENSION)}"))
        Aro::Mancy.game.draw(
          is_dt_dimension: Aro::T::is_dev_tarot?,
          z_max: Aro::Config.ivar(:Z_MAX).to_i,
          z: Aro::Config.ivar(:Z)
        )
      when CLI::CMDS[:DECK][:REPLACE]
        Aro::P.say(I18n.t("cli.messages.replacing_drawn", name: Aro::Mancy.game.name))
        Aro::Mancy.game.replace
      when CLI::CMDS[:DECK][:RESET]
        if Aro::Mancy::YES.to_s != Aro::P.p.ask("#{Aro::Mancy::PS1}#{I18n.t("cli.messages.confirmation_prompt", name: Aro::Mancy.game.name)}")
          Aro::P.say(I18n.t("cli.messages.understood", name: Aro::Mancy.game.name))
          exit(CLI::EXIT_CODES[:SUCCESS])
        end

        Aro::P.say(I18n.t("cli.messages.resetting", name: Aro::Mancy.game.name))
        Aro::Mancy.game.reset
      end

      if ARGV.include?(:aos.to_s)
        # run silent
        exit(CLI::EXIT_CODES[:SUCCESS])
      end

      Aro::Mancy.game.show(**CLI::shoptions)
    else
      Aro::Db.load
      Aro::Teck.select_teck(
        Aro::Teck.find_by(name: action)
      )
    end
  end
  
  # parse show options
  # todo: better naming
  def self.shoptions
    show_options_count = Aro::Mancy::S
    show_options_order = Aro::Tlog::ORDERING[:DESC]
    
    # Aro::D.say("ARGV.map{|a| a.to_sym} => #{ARGV.map{|a| a.to_sym}}")
    
    count_option_flags = ARGV.map{|a| a.to_sym} & CLI::FLAGS[:SHOW_COUNT]
    # Aro::D.say("count_option_flags: #{count_option_flags}")
    if count_option_flags.any?
      # get the ARGV index element after flag index
      show_options_count = ARGV[ARGV.index(count_option_flags.first.to_s) + 1]
      show_options_count = show_options_count.to_i unless [0, nil].include?(show_options_count&.to_i)
      # Aro::D.say("show_options_count: #{show_options_count}")
    end

    order_option_flags = ARGV.map{|a| a.to_sym} & CLI::FLAGS[:SHOW_ORDER]
    # Aro::D.say("count_option_flags: #{order_option_flags}")
    if order_option_flags.any?
      # get the ARGV index element after flag index
      show_options_order = ARGV[ARGV.index(order_option_flags.first.to_s) + 1].to_sym
      # Aro::D.say("show_options_order: #{show_options_order}")
    end

    {
      count_n: show_options_count,
      order_o: show_options_order
    }
  end

end

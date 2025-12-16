=begin
  
  dom.rb

  process dom commands.

  by i2097i

=end

module CLI
  def self.dom
    if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
      CLI.usage::usage
      exit(CLI::EXIT_CODES[:SUCCESS])
    end

    action = CLI::ARGV1&.to_sym

    CLI::Nterface.exit_error_invalid_usage! unless !action.nil? &&
      CLI::CMDS[:DOM].values.include?(action)

    case action
    when CLI::CMDS[:DOM][:INIT]
      if Aro::Dom.is_initialized?
        Aro::P.say(I18n.t("dom.errors.failed_already_initialized"))
      elsif Aro::Dom.in_arodom? && !Aro::Dom.is_initialized?
        arodome = Aro::Dom.new
        arodome.generate(ARGV[Aro::Mancy::OS], ARGV[Aro::Mancy::E])
      else
        CLI::Nterface.exit_error_invalid_usage!
      end
    when CLI::CMDS[:DOM][:NEW]
      CLI::Nterface.exit_error_missing_args! if CLI::ARGV2.nil?
      if Aro::Dom.in_arodom?
        Aro::P.say(I18n.t("dom.errors.failed_already_in_arodom"))
      elsif Aro::Mancy.in_aro?
        Aro::P.say(I18n.t("dom.errors.failed_in_aro_space"))
      else
        Aro::Dom.create(CLI::ARGV2.to_s)
      end
    end
  end
end

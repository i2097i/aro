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
      arodome = Aro::Dom.new
      arodome.generate
    when CLI::CMDS[:DOM][:NEW]
      CLI::Nterface.exit_error_missing_args! if CLI::ARGV2.nil?
      if Aro::Dom.in_arodom?
        # todo: i18n
        Aro::P.say("unable to create an arodome because you are already in arodom.")
      else
        Aro::Dom.create(CLI::ARGV2.to_s)
      end
    end
  end
end

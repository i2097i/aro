=begin
  
  dom.rb

  process dom commands.

  by i2097i

=end

module CLI
  def self.dom
    action = CLI::ARGV1&.to_sym

    CLI::Nterface.exit_error_invalid_usage! unless CLI::CMDS[:DOM].values.include?(action)

    if CLI::FLAGS[:HELP].include?(CLI::ARGV1)
      CLI.usage::usage
      exit(CLI::EXIT_CODES[:SUCCESS])
    elsif CLI::ARGV1.nil?
      # no args, default dom action
      Aro::Dom.map
    end

    case action
    when CLI::CMDS[:DOM][:MAP]
      Aro::Dom.map
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
    else
      if CLI::CMDS[:DOM].values.include?(action) 
        # todo: 
      end
    end
  end
end

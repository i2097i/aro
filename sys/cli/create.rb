=begin
  
  create.rb

  create aro space.

  by i2097i

=end

module CLI
  def self.create
    CLI::Nterface.exit_error_missing_args! if CLI::ARGV1.nil?
    
    name = CLI::ARGV1&.to_s
    Aro::P.say(I18n.t("cli.messages.creation_attempt", name: name))
    if Aro::Mancy.create(name)
      Aro::P.say(I18n.t("cli.messages.creation_success", name: name))
    else
      Aro::P.say(I18n.t("cli.messages.creation_failure", name: name))
    end
  end
end

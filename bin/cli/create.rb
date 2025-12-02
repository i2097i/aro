=begin
  
  constants.rb

  process aro creation commands

  by i2097i

=end

module CLI
  def self.create
    name = CLI::ARGV1.to_s || I18n.t("cli.messages.invalid_name")
    Aro::P.p.say(I18n.t("cli.messages.creation_attempt", name: name))
    Aro::Create.new(name)
  end
end

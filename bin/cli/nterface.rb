=begin
  
  nterface.rb

  cli nterface.

  by i2097i

=end

module CLI
  class Nterface
    def self.exit_error_missing_args!
      Aro::P.say(I18n.t("cli.errors.header"))
      Aro::P.say(I18n.t("cli.errors.missing_args", cmd: "#{CLI::ARGV0} #{CLI::ARGV1} #{CLI::ARGV2}".strip))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end
  end
end

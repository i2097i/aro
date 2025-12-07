=begin
  
  nterface.rb

  cli nterface.

  by i2097i

=end

module CLI
  class Nterface
    def self.exit_error_missing_args!
      Aro::P.say(I18n.t("cli.errors.header", cmd: Aro::Mancy::I2097I))
      Aro::P.say(I18n.t("cli.errors.missing_args", cmd: Aro::Mancy::I2097I))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end

    def self.exit_error_invalid_usage!
      Aro::P.say(I18n.t("cli.errors.header", cmd: Aro::Mancy::I2097I))
      Aro::P.say(I18n.t("cli.errors.invalid_usage", cmd: Aro::Mancy::I2097I))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end

    def self.exit_error_not_initialized!
      Aro::P.say(I18n.t("cli.errors.header", cmd: Aro::Mancy::I2097I))
      Aro::P.say(I18n.t("cli.errors.not_initialized", cmd: Aro::Mancy::I2097I))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end
  end
end

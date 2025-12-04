require :aro.to_s
[:cli].each do |dir|
  Dir[
    File.join(
      __dir__,
      dir.to_s,
      :"**/*.rb".to_s
    )
  ].each { |file| require file}
end

# set environment variable
ENV[:ARO_ENV.to_s] = :production.to_s
# ENV[:ARO_ENV.to_s] = :development.to_s

module CLI
  if CLI::LOAD_DECK_ACTIONS.keys.map{|k| k.downcase.to_sym}.include?(ARGV[0]&.to_sym)
    # enable deck shortcut (skip typing deck while in-game)
    ARGV0 = :deck
    ARGV1 = ARGV[0]&.to_sym
    ARGV2 = ARGV[1]&.to_sym
  else
    # default
    ARGV0 = ARGV[0]&.to_sym
    ARGV1 = ARGV[1]&.to_sym
    ARGV2 = ARGV[2]&.to_sym
  end

  class Aroface

    def self.exit_error_missing_args!
      Aro::P.say(I18n.t("cli.errors.header"))
      Aro::P.say(I18n.t("cli.errors.missing_args", cmd: "#{CLI::ARGV0} #{CLI::ARGV1} #{CLI::ARGV2}".strip))
      exit(CLI::EXIT_CODES[:INVALID_ARG])
    end

  end

end

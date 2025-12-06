=begin
  
  cli

  the very first file loaded.

  by i2097i

=end

module CLI
  # init config
  CLI::Config.instance
  
  if CLI::CMDS[:DECK].values.include?(ARGV[0]&.to_sym)
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
end
